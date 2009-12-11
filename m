From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: starting 90-second grace period
Date: Fri, 11 Dec 2009 16:30:05 +0530
Message-ID: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:42331 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945AbZLKLAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Dec 2009 06:00:18 -0500
Received: by iwn1 with SMTP id 1so354422iwn.33
        for <linux-nfs@vger.kernel.org>; Fri, 11 Dec 2009 03:00:25 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi all,

Is there anyway to reduce or remove "90-second grace period" ?

I could not find any configurable parameter.

grace_time seems to be derived from user_lease_time & lease_time.

what are the negative effects of changing *_lease_time ?

cheers
-- 
Tharindu Rukshan Bamunuarachchi
