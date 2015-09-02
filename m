Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36096 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbbIBTGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 15:06:34 -0400
Received: by lbcao8 with SMTP id ao8so11863115lbc.3
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2015 12:06:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150902185300.GA3319@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-3-git-send-email-agruenba@redhat.com>
	<20150902185300.GA3319@fieldses.org>
Date: Wed, 2 Sep 2015 21:06:32 +0200
Message-ID: <CAHc6FU62LQ8xnEbjsBprnud36AURg_ggifFoHOVM51-9vRJeDg@mail.gmail.com>
Subject: Re: [RFC v6 02/40] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-02 20:53 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> @@ -453,7 +453,8 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
>>   * this, letting us set arbitrary permissions for filesystem access without
>>   * changing the "normal" UIDs which are used for other things.
>>   *
>> - * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
>> + * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
>> + * MAY_WRITE must also be set in @mask.
>
> Why?

So that file systems that don't support MAY_APPEND can ignore the flag
and will then automatically check for MAY_WRITE instead.

> (Also: written as a simple list like that, it's a ambiguous how to
> parse that comment: I think you mean that MAY_WRITE must be set whenever
> MAY_APPEND, MAY_CREATE_FILE, or MAY_CREATE_DIR are set.)

Yes, that's better.

Thanks,
Andreas
