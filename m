From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: gssapi and nfs4
Date: Wed, 5 Nov 2008 14:40:23 -0500
Message-ID: <89c397150811051140p2f6e1cb1x1960570d19ac5d6d@mail.gmail.com>
References: <1225813410.2247.279.camel@brian-laptop>
	 <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
	 <1225824797.2247.345.camel@brian-laptop>
	 <20081104224817.GB16121@fieldses.org>
	 <1225862729.13506.8.camel@pc.interlinx.bc.ca>
	 <20081105190235.GA969@fieldses.org>
	 <1225912734.3785.40.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.239]:6962 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbYKETk1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 14:40:27 -0500
Received: by qb-out-0506.google.com with SMTP id e12so892563qbe.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2008 11:40:24 -0800 (PST)
In-Reply-To: <1225912734.3785.40.camel-lA68w17JHpfIgqYUaR6mlLDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 5, 2008 at 2:18 PM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> On Wed, 2008-11-05 at 14:02 -0500, J. Bruce Fields wrote:
>
>> Unfortunately that last option's the only practical approach right now.
>
> Other than exporting / of course.
>
>> We're working to simplify this.
>
> Great.
>
>> If you want to.  If you want to just mount the whole of / at one point
>> in the client filesystem, you can also do that, and the client will
>> automatically mount the filesystems underneath as it traverses into
>> them.
>
> That is cool.
>
>> > /   10.75.22.0/24(sec=krb5,ro,insecure,sync,wdelay,no_subtree_check,root_squash,fsid=0,crossmnt)
>> > /home   10.75.22.0/24(sec=krb5,rw,no_root_squash,sync,no_subtree_check)
>> > /d      10.75.22.0/24(sec=krb5,rw,no_root_squash,sync,no_subtree_check,crossmnt)
>> > /d/sub  pc(sec=krb5,rw,no_root_squash,sync,no_subtree_check)
>> >
>> > and on the clinet:
>> >
>> > pc # mount -t nfs4 -o sec=krb5 server:/ /mnt/server
>> > pc # mount -t nfs4 -o sec=krb5 server:/home /mnt/server/home
>> > pc # mount -t nfs4 -o sec=krb5 server:/d /d
>> > pc # mount -t nfs4 -o sec=krb5 server:/d/sub /d/sub
>> >
>> > To have /home rw under /mnt/server.  It would be there but ro without
>> > the second mount, yes?
>> >
>> > It also appears that for the above case of /d and /d/sub I need the
>> > crossmnt option on /d or I don't see anything in /d/sub even though I've
>> > exported and mounted it individually.  Does this seem like the expected
>> > behaviour or a bug?
>>
>> That's expected.
>
> But causes a problem as below...
>
>> > It's important to be able to do because I might
>> > want to be able to export /d to certain hosts without giving them access
>> > to mountpoints within /d as I have done above with /d/sub and pc.  If I
>> > use crossmnt which my experience is showing I need, then /d/sub is
>> > exposed to all of 10.75.22.0/24 which is not what I want.
>>
>> If you add a separate export for /d/sub, I think it should override that
>> behavior.
>
> That's what I did and still, I have to use crossmnt on /d and that
> exposes /d/sub it to everyone who gets access to /d where my intention
> is to only expose /d/sub to the match/limit I put on /d/sub, which is
> the single host "pc" in my above scneario.
>

A better way to limit access is to use ACL's on the directory, which
actually make a difference when running kerberos. :)

-->Andy


> Let me thank you for all of your great answers.
>
> b.
>
>
