Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46448 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbbH1SGP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2015 14:06:15 -0400
Date: Fri, 28 Aug 2015 14:06:12 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Mkrtchyan, Tigran'" <tigran.mkrtchyan@desy.de>,
        "'Ulrich Gemkow'" <ulrich.gemkow@ikr.uni-stuttgart.de>,
        linux-nfs@vger.kernel.org
Subject: Re: NFSv4 mount fails on Sun Solaris 10 after reboot of client
Message-ID: <20150828180612.GC10468@fieldses.org>
References: <201508241452.57718.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20150824201401.GA401@fieldses.org>
 <201508251928.06201.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20150825215456.GF8579@fieldses.org>
 <824431189.4182121.1440657831497.JavaMail.zimbra@desy.de>
 <20150827182922.GB11819@fieldses.org>
 <008901d0e108$13caa520$3b5fef60$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <008901d0e108$13caa520$3b5fef60$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2015 at 01:36:38PM -0700, Frank Filz wrote:
> > On Thu, Aug 27, 2015 at 08:43:51AM +0200, Mkrtchyan, Tigran wrote:
> > >
> > >
> > > ----- Original Message -----
> > > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > > To: "Ulrich Gemkow" <ulrich.gemkow@ikr.uni-stuttgart.de>
> > > > Cc: linux-nfs@vger.kernel.org
> > > > Sent: Tuesday, August 25, 2015 11:54:56 PM
> > > > Subject: Re: NFSv4 mount fails on Sun Solaris 10 after reboot of
> > > > client
> > >
> > > > On Tue, Aug 25, 2015 at 07:28:03PM +0200, Ulrich Gemkow wrote:
> > > >> Hello Bruce,
> > > >>
> > > >> On Monday 24 August 2015 22:14:01 J. Bruce Fields wrote:
> > > >> > On Mon, Aug 24, 2015 at 02:52:55PM +0200, Ulrich Gemkow wrote:
> > > >> > > we have a weired problem with Linux NFSv4.0 Server (Vanilla
> > > >> > > Kernel 4.1.6) and a Sun Solaris 10 client (all patches applied):
> > > >> > >
> > > >> > > When mounting a share on the Solaris client and then rebooting
> > > >> > > the client without unmounting the share first, after the reboot
> > > >> > > every attempt to mount the share again gives an I/O error on
> > > >> > > the client and the mount fails.
> > > >> > >
> > > >> > > After a long time (serveral hours) the v4 mount suddenly works
> > > >> > > again.
> > > >> > >
> > > >> > > Mounting a share with vers=2 works always even in times when
> > > >> > > the v4 mount fails.
> > > >> > >
> > > >> > > So it seems the Linux NFSv4 server holds a state for the client
> > > >> > > which prevents the re-mounting of the share and gives the
> > > >> > > I/O-error on the client.
> > > >> > >
> > > >> > > We use NFSv4 without idmapd.
> > > >> > >
> > > >> > > Is there any tip how to debug or solve this?
> > > >> >
> > > >> > Best is probably to get a packet trace.  So something like:
> > > >> >
> > > >> > 	tcpdump -s0 -iem0 -wtmp.pcap
> > > >> >
> > > >> > and then try the client mount, then kill the tcpdump after the
> > > >> > mount fails, and send us tmp.pcap.  (And/or take a look at
> > > >> > tmp.pcap yourself with wireshark.  The interesting question is
> > > >> > what kind of error the server is returning when the client tries
> > > >> > the mount after reboot.)
> > > >>
> > > >> Thank you for your reply. The tcpdump is attached, the relevant
> > > >> packets are 49..52. The error seems to be a SERVERFAULT. Can you
> > > >> see more from the dump?
> > > >>
> > > >> Thanks again and best regards
> > > >
> > > > The SERVERFAULT is on SETCLIENTID_CONFIRM.
> > > >
> > > > In nfsd4_setclientid_confirm():
> > > >
> > > >	conf = find_confirmed_client(clid, false, nn);
> > > >	unconf = find_unconfirmed_client(clid, false, nn);
> > > >	/*
> > > >         * We try hard to give out unique clientid's, so if we get an
> > > >         * attempt to confirm the same clientid with a different cred,
> > > >         * there's a bug somewhere.  Let's charitably assume it's our
> > > >         * bug.
> > > >         */
> > > >        status = nfserr_serverfault;
> > > >        if (unconf && !same_creds(&unconf->cl_cred, &rqstp->rq_cred))
> > > >                goto out;
> > > >        if (conf && !same_creds(&conf->cl_cred, &rqstp->rq_cred))
> > > >                goto out;
> 
> If the creds don't match, the return should be NFS4ERR_CLID_INUSE per
> section 16.34.5. IMPLEMENTATION first bullet after DRC discussion.
> 
> At least the way I read RFC 7530...

I assumed that was only the case when the long-form client-provided
client identifier matched, but here we're looking at records matched by
the shorthand server-generated clientid.  Very weird that that we'd get
to this case (and without hitting CLID_INUSE on the setclientid?).
There's something we don't understand.

Anyway, looking at the SETCLIENTID_CONFIRM description in 7530, I think
you're right, they're recommending CLIDN_INUSE for this case.  Doubt
that would actually help in Ulrich's case, though.

--b.
