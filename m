Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41752 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab1LDMsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:48:47 -0500
Received: by eaak14 with SMTP id k14so3580312eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 04:48:46 -0800 (PST)
Message-ID: <4EDB6C2B.9000803@tonian.com>
Date: Sun, 04 Dec 2011 14:48:43 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de
CC: linux-nfs@vger.kernel.org
Subject: Re: nfsv41: add current_stateid processing
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-04 14:03, tigran.mkrtchyan@desy.de wrote:
> current_stateid processing will allow clients to construct compounds
> like OPEN + READ + CLOSE or OPEN +LAYOUTGET.
> 
> As dCache server marks all layouts return-on-close, any open to a file followed
> by LAYOUTGET. A combined compound will allow to do the same in one go.
> 
> Currently linux client doesn't support it. But before we can get such functionality
> linux server have to support it as well. Here is an attempt to add it.
> 
> I made a dirty test with pynfs with to test OPEN+CLOSE in a single compound.
> If I read nfsd code correctly, READ and WRITE have to work as well. I will refactor
> pynfs a bit to easily construct such tests.

Cool!  Another interesting and meaningful tests could be OPEN + LOCK
and LOCKU + CLOSE

Benny

> 
> This is patches for preview to be sure that other server developers are happy with
> my approach before I change much more. 
> 
> Tigran.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
