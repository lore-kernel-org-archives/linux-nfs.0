From: "Dilip Kumar" <udilipkumar@gmail.com>
Subject: Re: Bug in NFSV3 ACCESS Procedure reply
Date: Thu, 28 Aug 2008 10:41:24 -0700
Message-ID: <9344d2ec0808281041w15e2738ew546531398f80a312@mail.gmail.com>
References: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com>
	 <20080828173424.GA3529@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:48154 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270AbYH1Rl0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2008 13:41:26 -0400
Received: by fg-out-1718.google.com with SMTP id 19so317661fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2008 10:41:24 -0700 (PDT)
In-Reply-To: <20080828173424.GA3529@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The directory was created by a local user (not root) with access mode
200 (Write only for owner). When I perform the ACCESS call as a owner
(who created that directory), I see that the ACCESS reply has access
set to 0x0. My /etc/exports just has just this one line :"/nfsshare
*(rw,sync)"

Thanks
Dilip Kumar

On Thu, Aug 28, 2008 at 10:34 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Aug 27, 2008 at 12:41:34PM -0700, Dilip Kumar wrote:
>> Hi all,
>>
>> I noticed a bug in the access rights of a NFSV3 ACCESS Reply. If a
>> directory was created with only write permissions for the owner (chmod
>> 200 directory), we expect the modify, extend and delete bits (access =
>> 0x1C) to be set for this directory in the reply to an ACCESS RPC call
>> with access = 0x1F send by the owner. Instead the NFS server on Linux
>> returns an ACCESS Reply with access set to 0x0 (none of the bits were
>> set). I tried checking this against Solaris server and it returns the
>> expected access rights 0x1C. The Linux server I was using for testing
>> was 2.6.9-1.667smp and the Solaris server was SunOS 5.8
>> Generic_108528-22 Ultra Sparc-IIi.
>
> What user are you performing the access call as, and who owns the
> directory?  What does exportfs -v say?   (Do you have root_squash or
> no_root_squash set?)
>
> --b.
>
>>
>> Please let me know if you need further details regarding this issue.
>>
>> Thanks
>> Dilip Kumar
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
