Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26C92C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 19:34:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AAF0720824
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 19:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Lp4DLQ5F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAF0720824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725790AbeJZEI3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 00:08:29 -0400
Received: from mail-qk1-f172.google.com ([209.85.222.172]:33211 "EHLO
        mail-qk1-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725784AbeJZEI3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 00:08:29 -0400
Received: by mail-qk1-f172.google.com with SMTP id o89so6497127qko.0;
        Thu, 25 Oct 2018 12:34:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:references:to:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=5+Mwjbc5C0fVVB6srwExcwag89teuB7cBsX0Y2hcn34=;
        b=Lp4DLQ5Fwgv4cUZkGAP9v9tHtqXoENQcZuHAccZulx12xv7W2/7cZfCu5+Rh/r966O
         M51fG5TNUFEV4UG8aXFCHSZkboW3e6B2+wUBtsn2TGBNQ3X1PuVNvOIREvRZ0WrHuQ4s
         2pWu7JtFIchU3CVairAeI2hDvWjdLeDgdUf435Y8mVCrIGv+qdAx218oHfVUq2TTFJUv
         Ynuzw6xZ4VmGve98kZ8hoYO9NmBd4jWnQGJ0/oTwrOvqBlqt3f6r1ORUvjKSB0yzHf/j
         H1cj0NMUns44S5Hyv7YqpB3GxLqP1zEs4B5Tfcqhq90xqHOWikk0zNJCcdQepyQJgiff
         lZIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:references:to:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=5+Mwjbc5C0fVVB6srwExcwag89teuB7cBsX0Y2hcn34=;
        b=Q8G0PA+Yg00QZuhTeK5ye+8TW1+QgsBrvwF912pkKh94joL57aJXHgcI03LDIryJT9
         8tZDaRM2zLmW+aS0ROV+58DT7ix6ypT9hYsOP3eSN3lVDsFwP1vefRZTQKhXhQX61EyF
         K+UvWDq/khbN2gR0ogbgjdgYslWy0FjwFiHTbTSFWuUEkcSLDooHEYOfUBlwV0R7euc5
         XStBUySSNPdVu1g53FzO5HqNlj11AugBbeySOZGD0AcJTUEN1msyFtXu93s0XJiMDIjD
         C+LyhZi+0D1HiUJ/zOjEoe+ghLU8FuKqAC77MNah8uajiL+JHu54kAMO+6GR11fQ6ZAy
         62hQ==
X-Gm-Message-State: AGRZ1gLPd+5wN6UKNWItsetKPwgMYUuj8jPDeIX4slrYPAReRvviTFAd
        0BSb7Vkq+8nuX7xpV/Yfy0q/Hyrs
X-Google-Smtp-Source: AJdET5ckS3Fx0yanWm7ayA2Mjz7elCaI1x5fPZmKJtADo91yQal7mMXJtZr3aIpPpJEjwx9TgeDKPQ==
X-Received: by 2002:ae9:edd8:: with SMTP id c207mr508095qkg.184.1540496062623;
        Thu, 25 Oct 2018 12:34:22 -0700 (PDT)
Received: from [192.168.1.204] (pool-173-48-195-86.bstnma.fios.verizon.net. [173.48.195.86])
        by smtp.gmail.com with ESMTPSA id u123-v6sm4917359qkd.51.2018.10.25.12.34.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 12:34:21 -0700 (PDT)
Subject: Vault '19 Submission Deadline Approaching
References: <UTAYUBCWXT$UYXTXCYAXZWUC@mail-out.via.act-on.net>
To:     Linux NFS list <linux-nfs@vger.kernel.org>,
        device-mapper development <dm-devel@redhat.com>,
        linux-btrfs <linux-btrfs@vger.kernel.org>
From:   Ric Wheeler <ricwheeler@gmail.com>
X-Forwarded-Message-Id: <UTAYUBCWXT$UYXTXCYAXZWUC@mail-out.via.act-on.net>
Message-ID: <67e9d4f8-06fb-ee33-451c-96c73bbd0e0e@gmail.com>
Date:   Thu, 25 Oct 2018 15:34:20 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.0
MIME-Version: 1.0
In-Reply-To: <UTAYUBCWXT$UYXTXCYAXZWUC@mail-out.via.act-on.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi all,

If anyone is interested in giving a talk at the open source storage conference - 
formerly hosted by the Linux Foundation, but now co-located with USENIX FAST - 
this first event in the new series will be in Boston next to FAST this coming year.

It would be great to have a good showing for this, we hope to show that open 
source file & storage systems are worth investing in!

Details at: https://www.usenix.org/conference/vault19

Regards,

Ric
-------- Forwarded Message --------
Subject: 	Vault '19 Submission Deadline Approaching
Date: 	Thu, 25 Oct 2018 12:29:06 -0700 (PDT)
From: 	Ric Wheeler <ric.wheeler@usenix.org>
Reply-To: 	Ric Wheeler <ric.wheeler@usenix.org>
To: 	Ric Wheeler <ricwheeler@gmail.com>



Vault '19 Talk and Workshop Proposals Are Due in Three Weeks….


Vault '19, February 25–26, 2019, Boston, MA, USA 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct0_0/1?sid=TV2%3AIa0q01yIk>

Dear Ric,

In case you missed the announcement, the Linux Storage and Filesystems 
Conference (Vault) returns on February 25–26, 2019, in Boston, MA, USA, under 
the sponsorship and organization of the USENIX Association. Vault '19 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct0_1/1?sid=TV2%3AIa0q01yIk> 
will be co-located with the 17th USENIX Conference on File and Storage 
Technologies (FAST '19 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct1_0/1?sid=TV2%3AIa0q01yIk>).

We invite you to submit talk and workshop proposals related to open source 
storage, file systems, Linux, and related technologies. The best talks will 
share your or your team's experience with a new technology, a new idea, a new 
approach, or inspire the audience to think beyond the ways they have always done 
things.

Proposals are due in just a few weeks, on *Thursday, November 15*. Please read 
through the Call for Participation 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct2_0/1?sid=TV2%3AIa0q01yIk> 
for additional details, including topics of interest, and submission instructions.

We look forward to receiving your proposals!

Ric Wheeler, /Red Hat/
Christoph Hellwig
Erik Riedel
Vault '19 Program Co-Chairs
vault19chairs@usenix.org <mailto:vault19chairs@usenix.org>

/Please use vault19chairs@usenix.org <mailto:vault19chairs@usenix.org> to 
contact Ric Wheeler, Christoph Hellwig, and Erik Riedel. The email address 
ric.wheeler@usenix.org <mailto:ric.wheeler@usenix.org> is for automated list 
management only./

--------------------------------------------------------------------------------

*YOUR OPINION MATTERS!*

Give USENIX feedback about how we're doing by taking a 20-minute survey. 
Complete the survey to be entered into a random drawing to win registration to 
the USENIX conference of your choice plus conference hotel accommodations!

Begin the survey now 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct3_0/1?sid=TV2%3AIa0q01yIk>.

--------------------------------------------------------------------------------

About this mailing list:

USENIX 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct4_0/1?sid=TV2%3AIa0q01yIk> 
never shares, sells, rents, or exchanges email addresses of its members, 
conference attendees, and other constituents. Review our privacy policy 
<http://s.usenix.org/acton/ct/2452/s-02cb-1810/Bct/l-sf-cl-7011M000001R0hBQAS-23c0/l-sf-cl-7011M000001R0hBQAS-23c0:27/ct5_0/1?sid=TV2%3AIa0q01yIk>.

We would like to continue sending you occasional email announcements like this 
one. However, if you no longer want to receive emails from USENIX, please click 
here 
<http://s.usenix.org/acton/rif/2452/s-02cb-1810/-/l-sf-cl-7011M000001R0hBQAS-23c0:27/l-sf-cl-7011M000001R0hBQAS-23c0/zout?sid=TV2%3AIa0q01yIk> 
to opt out.

If you have any questions about the mailing list, please email office@usenix.org 
<mailto:office@usenix.org?subj=mailing%20list%20question>. We may also be 
reached via postal mail:

USENIX Association
2560 Ninth St, Suite 215, Berkeley, CA 94710, USA

