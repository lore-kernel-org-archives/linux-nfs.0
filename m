Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57416 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab1GGPLP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 11:11:15 -0400
Received: by wyg8 with SMTP id 8so715505wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2011 08:11:14 -0700 (PDT)
Message-ID: <4E15CC5D.6070108@fubra.com>
Date: Thu, 07 Jul 2011 16:10:21 +0100
From: Matthew Ward <matthew.ward@fubra.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Issue with NFS and LDAP, attribute caching with "Permission denied"
References: <4E15C555.9030002@fubra.com>
In-Reply-To: <4E15C555.9030002@fubra.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Using exportfs -rf seems to solve the issue, and I'm happy that it's not 
going to happen often enough and not cause too much of a performance hit 
to be happily run every time we add a random user and group to the 
server. If anyone has any further insight, I'd be happy to discuss.

============
Matthew Ward
Web and Mobile Application Developer
Fubra Limited

w: www.fubra.com
e: matthew.ward@fubra.com

------------------------------

Fubra is a company limited by shares and registered in England and
Wales with number 3967214 at Anstey Park House, Anstey Road,
Alton, Hampshire, GU34 2RL. We are registered for VAT with number
GB733667024, and as a data controller with number Z5193400.
We are members of RIPE, Nominet, The Italian RA and registered
with OfCom as a provider of electronic communications services.

