From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: Union mounts, NFS, and locking
Date: Wed, 15 Jul 2009 20:15:03 -0400
Message-ID: <200907160015.n6G0F3h6015435@agora.fsl.cs.sunysb.edu>
References: <1247612140.5332.11.camel@heimdal.trondhjem.org>
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Valerie Aurora <vaurora@redhat.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:57846 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbZGPAPl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 20:15:41 -0400
In-reply-to: Your message of "Tue, 14 Jul 2009 18:55:40 EDT."
             <1247612140.5332.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <1247612140.5332.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>, Trond Myklebust writes:
> On Tue, 2009-07-14 at 18:33 -0400, Erez Zadok wrote:
> > How would the client detect that the server broke the promise?  In theory,
> > your client may never know b/c it'll never send the server any
> > state-changing ops (e.g., creat, write, unlink).  One really ugly idea might
> > be for the client to try and create a dummy .nfsXXXXXX file on the server,
> > and if that succeds, or the error returned isn't EROFS, the client can guess
> > that the server's misbhaving.
> 
> That still doesn't guarantee anything:
> 
> cat /etc/exports
> /export	10.0.0.0/24(ro,sync) 10.0.1.1(rw,sync)
> /export/home 10.0.0.0/24(sec=krb5i:krb5p,rw,sec=sys:krb5,ro)

Agreed.  One more example why trying to enforce read-only-ness (or any other
term Bruce prefers :-) is going to be too hard to do at this stage.  I think
we can live with a client-side "promise" via a mount option for now.

> Both of the above are liable to return EROFS to some clients, but not
> others...
> 
> NFSv4.1 directory delegations can do the job of notifying you if the
> directory contents change, but what should your unionfs do when it gets
> told that this is the case?

Good to know about these delegations in 4.1.  They could be useful for any
stackable layer including union mounts and even ecryptfs, to handle cache
coherency across the layers more gracefully.  At the very least it could be
used to purge stale caches.  Even w/ union mounts, some operations could be
expensive: e.g., directory name merging and duplicate elimination; hence
it's likely the result of such a merge would be cached somewhere.  This
cache can get stale if a directory that's part of the name merge has changed
on the server.  So a unioning solution might want to know this.

(Directory delegations may also be more efficient than the traditional
NFSv2/3 way to validating the attrcache; IIRC, the client has to check that
the parent dir mtime hasn't changed before using a cached attribute.)

BTW, will nfs4.1's directory delegations be able to inform about namespace
changes only, or would they also be able to inform the client about file
data which had changed.

> Cheers
>   Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

Thanks,
Erez.
