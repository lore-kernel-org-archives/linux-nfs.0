Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40498 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbZDNMkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2009 08:40:55 -0400
Subject: Re: Unexplained NFS mount hangs
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Rudy@grumpydevil.homelinux.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Daniel Stickney <dstickney@pronto.com>, linux-nfs@vger.kernel.org
In-Reply-To: <1239712656.13583.80.camel@poledra.romunt.nl>
References: <20090413092406.304d04fb@dstickney2>
	 <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
	 <20090413104759.525161b2@dstickney2>
	 <48017BBF-03BD-4C87-84F1-1D3603273E4F@oracle.com>
	 <1239650707.13583.49.camel@poledra.romunt.nl>
	 <1239700583.13583.62.camel@poledra.romunt.nl>
	 <1239712286.16771.39.camel@heimdal.trondhjem.org>
	 <1239712656.13583.80.camel@poledra.romunt.nl>
Content-Type: text/plain
Date: Tue, 14 Apr 2009 08:40:45 -0400
Message-Id: <1239712845.16771.53.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-04-14 at 14:37 +0200, Rudy Zijlstra wrote:
> Op dinsdag 14-04-2009 om 08:31 uur [tijdzone -0400], schreef Trond
> Myklebust:
> > On Tue, 2009-04-14 at 11:16 +0200, Rudy Zijlstra wrote:
> > > Op maandag 13-04-2009 om 21:25 uur [tijdzone +0200], schreef Rudy
> > > Zijlstra:
> > > > Op maandag 13-04-2009 om 13:08 uur [tijdzone -0400], schreef Chuck
> > > > Lever:
> > > > > On Apr 13, 2009, at 12:47 PM, Daniel Stickney wrote:
> > > > > 
> > > > > > On Mon, 13 Apr 2009 12:12:47 -0400
> > > > > > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > > > >
> > > > > >> On Apr 13, 2009, at 11:24 AM, Daniel Stickney wrote:
> > > > > >>> Hi all,
> > > > > >>>
> > > > > >>> I am investigating some NFS mount hangs that we have started to see
> > > > > >>> over the past month on some of our servers. The behavior is that the
> > > > > >>> client mount hangs and needs to be manually unmounted (forcefully
> > > > > >>> with 'umount -f') and remounted to make it work. There are about 85
> > > > > >>> clients mounting a partition over NFS. About 50 of the clients are
> > > > > >>> running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of
> > > > > >>> these 50 has ever had this mount hang. The other 35 are CentOS 5.2
> > > > > >>> with kernel 2.6.27 which was compiled from source. The mount hangs
> > > > > >>> are inconsistent and so far I don't know how to trigger them on
> > > > > >>> demand. The timing of the hangs as noted by the timestamp in /var/
> > > > > >>> log/messages varies. Not all of the 35 CentOS clients have their
> > > > > >>> mounts hang at the same time, and the NFS server continues operating
> > > > > >>> apparently normally for all other clients. Normally maybe 5 clients
> > > > > >>> have a mount hang per week, on different days, mostly different
> > > > > >>> times. Now and then we might see a cluster of a few clien
> > > > > >>> ts have their mounts hang at the same exact time, but this is not
> > > > > >>> consistent. In /var/log/messages we see
> > > 
> > > 
> > > > OK, i'll switch to 2.6.30 on all clients once it is out. Prefer to wait
> > > > for release, as they are production type machines. 
> > > > 
> > > > If i get a hang, i'll check with "netstat --ip"
> > > > 
> > > 
> > > Just now one of my 2.6.28.7 machines is hanging. 
> > > netstat results in client status: 
> > > tcp  0  0 mythm.romunt.nl:1020    repeater.romunt.nl:nfsd FIN_WAIT2
> > > tcp 76  0 mythm.romunt.nl:6544    repeater.romunt.n:53854 ESTABLISHED
> > > 
> > >  
> > > and on the server i find:
> > > tcp  1  0 repeater.romunt.nl:nfsd mythm.romunt.nl:1020    CLOSE_WAIT 
> > > tcp  0  0 repeater.romunt.n:53854 mythm.romunt.nl:6544    FIN_WAIT2  
> > > 
> > 
> > Which shows that the NFS server is failing to close the tcp connection
> > after the client has closed on its side.
> > 
> > You probably want to apply this patch to your server:
> >     http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a
> > 
> > 
> > Trond
> > 
> 
> Hi Trond
> 
> Thanks, would an upgrade to 2.6.29.1 also work? 

Yes. That same patch should also be in 2.6.29.

Cheers
  Trond

