Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:27982 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbaCFFDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 00:03:49 -0500
Date: Wed, 5 Mar 2014 23:03:43 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <20140306145042.6db53f60@notabene.brown>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "NeilBrown" <neilb@suse.de>
> To: "Andrew Martin" <amartin@xes-inc.com>
> Cc: linux-nfs@vger.kernel.org
> Sent: Wednesday, March 5, 2014 9:50:42 PM
> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
> 
> On Wed, 5 Mar 2014 11:45:24 -0600 (CST) Andrew Martin <amartin@xes-inc.com>
> wrote:
> 
> > Hello,
> > 
> > Is it safe to use the "soft" mount option with proto=tcp on newer kernels
> > (e.g
> > 3.2 and newer)? Currently using the "defaults" nfs mount options on Ubuntu
> > 12.04 results in processes blocking forever in uninterruptable sleep if
> > they
> > attempt to access a mountpoint while the NFS server is offline. I would
> > prefer
> > that NFS simply return an error to the clients after retrying a few times,
> > however I also cannot have data loss. From the man page, I think these
> > options
> > will give that effect?
> > soft,proto=tcp,timeo=10,retrans=3
> > 
> > >From my understanding, this will cause NFS to retry the connection 3 times
> > >(once
> > per second), and then if all 3 are unsuccessful return an error to the
> > application. Is this correct? Is there a risk of data loss or corruption by
> > using "soft" in this way? Or is there a better way to approach this?
> 
> I think your best bet is to use an auto-mounter so that the filesystem gets
> unmounted if the server isn't available.
Would this still succeed in unmounting the filesystem if there are already
processes requesting files from it (and blocking in uninterruptable sleep)?

> "soft" always implies the risk of data loss.  "Nulls Frequently Substituted"
> as it was described to very many years ago.
> 
> Possibly it would be good to have something between 'hard' and 'soft' for
> cases like yours (you aren't the first to ask).
> 
>  From http://docstore.mik.ua/orelly/networking/puis/ch20_01.htm
> 
>    BSDI and OSF /1 also have a spongy option that is similar to hard , except
>    that the stat, lookup, fsstat, readlink, and readdir operations behave
>    like a soft MOUNT .
> 
> Linux doesn't have 'spongy'.  Maybe it could.  Or maybe it was a failed
> experiment and there are good reasons not to want it.

The problem that sparked this question is a webserver where apache can serve
files from an NFS mount. If the NFS server becomes unavailable, then the apache
processes block in uninterruptable sleep and drive the load very high, forcing
a server restart. It would be better for this case if the mount would simply 
return an error to apache, so that it would give up rather than blocking 
forever and taking down the system. Can such behavior be achieved safely?
