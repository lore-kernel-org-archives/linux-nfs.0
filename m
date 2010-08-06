Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37948 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab0HFE02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 00:26:28 -0400
Date: Fri, 6 Aug 2010 14:26:18 +1000
From: Neil Brown <neilb@suse.de>
To: Jason Keltz <jas@cse.yorku.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: exporting to a list of IPs
Message-ID: <20100806142618.2268f332@notabene>
In-Reply-To: <Pine.LNX.4.63.1008052140560.25210@indigo.cs.yorku.ca>
References: <4C583B63.4050903@cse.yorku.ca>
	<20100804134527.146397ff@notabene>
	<4C596F81.6010409@cse.yorku.ca>
	<20100805081311.727e9185@notabene>
	<Pine.LNX.4.63.1008052140560.25210@indigo.cs.yorku.ca>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 5 Aug 2010 21:42:09 -0400 (EDT)
Jason Keltz <jas@cse.yorku.ca> wrote:

> On Thu, 5 Aug 2010, Neil Brown wrote:
> 
> > On Wed, 04 Aug 2010 09:47:45 -0400
> > Jason Keltz <jas@cse.yorku.ca> wrote:
> >
> >> Neil Brown wrote:
> >>> On Tue, 03 Aug 2010 11:53:07 -0400
> >>> Jason Keltz <jas@cse.yorku.ca> wrote:
> >>>
> >>>> Hi.
> >>>>
> >>>> Why is it that you cannot NFS export to a list of IPs and have exportfs
> >>>> leave the list of IPs in etab without converting over to FQDN?
> >>>
> >>> My memory is that if you only list IP addresses in /etc/exports then it will
> >>> do just want you want.  But if you list any host names or net groups then it
> >>> has to do a DNS lookup on everything to see if either of those matches.
> >>
> >> Hi Neil.
> >>
> >> Thanks for your response!
> >>
> >> Actually, if I list ONLY IPs in /etc/exports, and nothing else, then
> >> etab gets converted over to using hostnames:
> >>
> >> For example:
> >>
> >> # cat /etc/exports
> >> /test 130.63.92.24(ro,sync)
> >>
> >> # cat /var/lib/nfs/etab
> >> (it's empty)
> >> # exportfs -a
> >> # cat /var/lib/nfs/etab
> >> /test
> >> gold.cs.yorku.ca(ro,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
> >>
> >> In fact, I see two problems here.  First, exportfs shouldn't convert
> >> etab over to using FQDN.  Second, if it does do this, I don't see why
> >> rpc.mountd needs to RE-resolve each hostname in etab.    During this
> >> time (right after exportfs exits), all of my NFS shares hang, and an
> >> strace of rpc.mountd shows that it is re-resolving all the hostnames
> >> from etab.  When it finishes, all activity continues.  On one system
> >> with a total of 30,000 hostnames listed, this ends up in a 30 second
> >> hang time for all NFS exports!  I was able to shrink this time slightly
> >> by putting a caching name server on the NFS server, so that the NFS
> >> server wasn't killing the DNS, but this didn't help enough.  If exportfs
> >> truly has to convert IPs over to hostname, I can live with that, but
> >> then rpc.mountd shouldn't re-resolve the names.  If both can live with
> >> IPs, I'm good with that as well.
> >>
> >> Now, albeit, I'm using an older nfs-utils that comes with RHEL4
> >> installation.  Compiling a later version is a bit tricky because some
> >> libraries have changed.  That being said, reviewing the source (given
> >> that I don't really know it that well) for the newest nfs-utils, I don't
> >> see how this behavior would really be any different.  For example, in
> >> client_lookup in support/export/client.c, adding some printfs, I can see
> >> that the IPs always get into the ...
> >>
> >>    if (htype == MCL_FQDN && !canonical) {
> >> ... where there's a call to gethostbyname.
> >>
> >> This is the same in nfs-utils-1.0.6 as it is in 1.2.2.
> >
> > True, but client_gettype is different.
> > In 1.0.6, w.x.y.z is treated as MCL_FQDN
> > In 1.2.2, w.x.y.z is treated as MCL_SUBNETWORK
> >
> > If you use w.x.y.z/32 then it will be treated as MCL_SUBNETWORK and should do
> > what you want.
> 
> Hi Neil,
> 
> I tried this, and it worked wonderfully! Well, sort of.  It appears that 
> mountd doesn't care about the mask, since I can set it to /1, /24, or /32 
> and it works...  I'm disappointed to say that after exportfs exits, my NFS 
> shares still hang for around 20 seconds.  Now it seems like this is 
> happening while rpc.mountd is doing a whole bunch of lstat64 calls! I 
> guess that comes after what used to be the name lookups.  I just don't get 
> it.  I wrote a small program to loop through 38,000 lstat64 calls in a 
> matter of a second... if you could look at the lstat output here 
> (http://www.cse.yorku.ca/~jas/lstat.txt), it would be really helpful .. i 
> added the times so you can see how long all the lstats take.  It's crazy.
> 
>

I think it does care about the mask.

192.168.1.1/1  means any address where the first 1 bit is the same as this
address,
192.168.1.1/16 means the first 16 - so 192.168.*.*
192.168.1.1/32 means exactly 192.168.1.1, nothing else.

Your /var/lib/nfs/etab is 3 megabytes and appears to have about 18000 entries
and this takes about 24 seconds to process so 750 per second on average.
Of course it isn't just stating the files, it is also building up an internal
data structure to hold it all, and quite possibly doing linear searches to
make sure there aren't any duplicates resulting in quadratic behaviour.
If you look at the number of stats per second it starts at over 2000 and by
then end it is around 300.

Do you really need that many entries?  I note there are 22 different
directories being exported each to 858 ip addresses.  Are they really all
distinct addresses or can you use a larger subnet mask to group some of them
together?

NeilBrown
