From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [autofs] Re:  bug in linux mount? (says NetApp)
Date: Wed, 12 Jul 2006 08:19:39 -0400
Message-ID: <1152706779.6292.18.camel@lade.trondhjem.org>
References: <44B3F547.9010507@amd.com>
	<1152660478.5681.38.camel@lade.trondhjem.org>
	<1152673424.2930.15.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, gregory.baker@amd.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0dhP-0000QD-K0
	for nfs@lists.sourceforge.net; Wed, 12 Jul 2006 05:20:15 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G0dhN-0002zo-Ea
	for nfs@lists.sourceforge.net; Wed, 12 Jul 2006 05:20:16 -0700
To: Ian Kent <raven@themaw.net>
In-Reply-To: <1152673424.2930.15.camel@raven.themaw.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-07-12 at 11:03 +0800, Ian Kent wrote:
> On Tue, 2006-07-11 at 19:27 -0400, Trond Myklebust wrote:
> > Something like
> > 
> > mount -t nfs -ohard,timeo=600,retrans=2,rsize=32768,wsize=32768,tcp foo:/ /bar
> 
> I thought that the default timeo had changed to 600 (60 secs) for TCP
> mounts in later versions of mount (it should be) and that the retrans
> shouldn't matter as 60 secs is the RPC major timeout. I thought the
> point of this default was to prevent RPC from retransmitting as the TCP
> la
> > should be a fairly safe bet. You might want to add the 'intr' flag too,
> > depending on how you feel about the behaviour w.r.t. pressing ^C.
> > 
> > > * What is the reference standard behavior?
> 
> I don't think it's a standard in as much as it's common sense.
> Certainly if the defaults are set to those that are sensible for UDP you
> are much more likely to bogus failures.
> 
> Ian
> yer would take care of it. 
> 
> Trond what am I missing.

The fact that not everyone may be using a recent version of mount :-)
The above line should work fine with all versions.

Actually, the "retrans" value is pretty irrelevant for hard mounts. It
is more important for soft mounts for which it defines the number of
resends before giving up the RPC call and returning an error to the
application.

Cheers,
  Trond



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
