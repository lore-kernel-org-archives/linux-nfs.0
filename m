Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-3.concepts.nl ([213.197.30.127]:45079 "EHLO
	smtp-3.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaJSRr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Oct 2014 13:47:27 -0400
Message-ID: <5443F5A1.1050004@xmsnet.nl>
Date: Sun, 19 Oct 2014 19:32:17 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot
 laptop
References: <543ED24D.4070905@xmsnet.nl>
In-Reply-To: <543ED24D.4070905@xmsnet.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2014 10:00 PM, Hans de Bruin wrote:
> After playing an old dos game i am missing files on my nfsroot installed
> laptop. Which one, wel /bin/ls is at least one of them. After a reboot
> there all back again.  But not al is well. Some icons on my kde panel
> where gone. I have seen this twice in the last day's
>

The problem appears immediately after starting dosemu so this bisectable

-- 
Hans

