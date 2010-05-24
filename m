From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Deadlock in NFSv4 in all kernels
Date: Mon, 24 May 2010 23:24:23 +0200
Message-ID: <20100524212422.GA1286@ucw.cz>
References: <20100507153920.GP28167@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, salvet@ics.muni.cz
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100507153920.GP28167@ics.muni.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

> I encountered the following problem. We use short expiration time for
> kerberos contexts created by rpc.gssd (some patches were included in mainline
> nfs-utils). In particular, we use 120secs expiration time.
> 
> Now, I run application that eats 80% of available RAM. Then I run 10 parallel
> dd processes that write data into NFS4 volume with sec=krb5.
> 
> As soon as the kerberos context expires (i.e., up to 120 secs), the whole
> system gets stuck in do_page_fault and succesive functions. It is because
> there is no free memory in kernel, all free memory is used as cache for NFS4
> (due to dd traffic), kernel ask NFS to write back its pages but NFS cannot do
> anything as it is missing valid context. NFS contacts rpc.gssd to provide
> a renewed context, the rpc.gssd does not provide the context as it needs some memory
> to scan /tmp for a ticket. I.e., it deadlocks.
> 
> Longer context expiration time is no real solution as it only makes the
> deadlock less often. 
> 
> Any ideas what can be done here? (Please cc me.) We could preallocate some
> memory in rpc.gssd and use mlockall but not sure whether this proctects also
> kernel malloc for things related to rpc.gssd and context creation (new file
> descriptors and so on). 
> 
> This is seen in 2.6.32 kernel but most probably this is related to all kernel
> versions.

Seems like pretty fundamental problem in nfs :-(. Limiting writeback
caches for nfs, so that system has enough memory to perform rpc calls
with the rest might do the trick, but...

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
