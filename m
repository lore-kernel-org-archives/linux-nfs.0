From: "Feng Shuo" <fengshuo-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: Re: about NLM/NSM
Date: Wed, 29 Oct 2008 09:20:45 +0800
Message-ID: <88c6482d0810281820k7fee74f7x3ab8a6cb6bde4688@mail.gmail.com>
References: <55BA1E9645B3441FA782D9032BDC9288@nrchpcvx1f5w93>
	 <20081027185515.GB23767@fieldses.org> <49061511.4050304@redhat.com>
	 <20081027201323.GA25467@fieldses.org> <49062F3E.6090206@redhat.com>
	 <20081027211740.GC25467@fieldses.org> <490630AE.4000807@redhat.com>
	 <1225215096.28654.18.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	hexf <hexiaofeng-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	"=?GB2312?B?UGVpZmVuZyBMSVUgKMH1xeC35Sk=?=" <liupeifeng-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
To: "Frank Filz" <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:41457 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbYJ2BUs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2008 21:20:48 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1134744nfc.21
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2008 18:20:45 -0700 (PDT)
In-Reply-To: <1225215096.28654.18.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you all very much. Hexf and I are examing all the clues together
to check whether we can get a clearer solution. He will post the
result later.

Feng Shuo
2008/10/29 Frank Filz <ffilzlnx@us.ibm.com>:
> On Mon, 2008-10-27 at 17:20 -0400, Peter Staubach wrote:
>> J. Bruce Fields wrote:
>> > On Mon, Oct 27, 2008 at 05:14:38PM -0400, Peter Staubach wrote:
>> >
>> >> J. Bruce Fields wrote:
>> >>
>> >>> On Mon, Oct 27, 2008 at 03:22:57PM -0400, Peter Staubach wrote:
>> >>>
>> >>>
>> >>>> J. Bruce Fields wrote:
>> >>>>
>> >>>>
>> >>>>> On Mon, Oct 27, 2008 at 02:49:27PM +0800, hexf wrote:
>> >>>>>
>> >>>>>
>> >>>>>> We are using nfsv3. Now we meet a demand. If a client which hold a
>> >>>>>> lock crash, after it reboot, its statd daemon can notify the nfs
>> >>>>>> server to release the lock.  But if this client will not reboot for
>> >>>>>> some reason(or will reboot after a long time), then the lock it
>> >>>>>> holding will not be released.In nfsv3 and nlmv4,it seems there is no
>> >>>>>> time-out mechnism for this situation. How would we solve this
>> >>>>>> question? My colleague advise me to modify the code of NLM/NSM to meet
>> >>>>>> this demand,but is seems quite a complicated work.Can you give me some
>> >>>>>> advice?
>> >>>>>>
>> >>>>>>
>> >>>>> It might be possible to modify the server so that it dropped all locks
>> >>>>> from a client it hadn't heard from in a while.  However, nfsv2/v3
>> >>>>> clients are not required to contact the server regularly while they hold
>> >>>>> locks.  So you may end up revoking locks held by perfectly good
>> >>>>> functioning clients.
>> >>>>>
>> >>>>> As an ugly workaround, rebooting the server will clear the problem, as
>> >>>>> it will notify clients to recover their locks on restart, and any dead
>> >>>>> clients will fail to recover their locks.
>> >>>>>
>> >>>>>
>> >>>>>
>> >>>> Didn't Wendy Cheng submit some patches to implement a
>> >>>> "clearlocks" sort of functionality?  What happened with
>> >>>> them?
>> >>>>
>> >>>>
>> >>> Yes, but that's motivated by the case of migrating all clients using one
>> >>> export; so it'll drop all locks held on a single filesystem, or all
>> >>> locks acquired using a single server (not client!) ip address.
>> >>>
>> >>> So if we want some finer-grained interface then that's yet to be
>> >>> designed.
>> >>>
>> >>>
>> >> Sorry, I guess that I was remembering incorrectly.  I was
>> >> thinking that she was looking for something like the clearlocks
>> >> functionality so that file systems could be migrated around
>> >> cleanly.
>> >>
>> >
>> > That's what she was working on (and we merged), yes.
>> >
>> > But it doesn't help clear just the set of locks held by a single client.
>> >
>> >
>> >> It seems for this situation, we could use this sort of variation.
>> >>
>> >
>> > I'm losing track of what those two "this"'s refer to!
>> >
>>
>> Sorry -- :-)
>>
>> For the situation of needing to clear locks belonging to long
>> dead and not returning clients, we could use a variation of
>> Wendy's proposal which works using the client IP as the key.
>
> Wouldn't this be pretty easy to do with a user space tool that just
> calls lockd's SM_NOTIFY procedure? Sure, it's a private interface (as
> far as what proc # - but it's pretty well known that lockd always
> provides SM_NOTIFY on the same proc #), but there's no real need to add
> a new kernel interface unless we want to generalize the clearlocks
> interface.
>
> The tool just needs to use loopback and a privileged port.
>
> Frank
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Feng Shuo
Tel: (86)10-6260-0547
Fax: (86)10-6265-7255
Mailing: P. O. Box 2704# Beijing
Postcode: 100080
National Research Centre for High Performance Computers
Institute of Computing Technology, Chinese Academy of Sciences
No. 6, South Kexueyuan Road, Haidian District
Beijing, China
