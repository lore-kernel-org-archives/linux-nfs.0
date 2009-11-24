Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:43760 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932851AbZKXU2d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 15:28:33 -0500
Received: by ywh12 with SMTP id 12so6798883ywh.21
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2009 12:28:39 -0800 (PST)
Message-ID: <4B0C4116.10903@dyfis.net>
Date: Tue, 24 Nov 2009 14:24:54 -0600
From: Charles Duffy <charles@dyfis.net>
To: Peter Staubach <staubach@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
References: <hehc8g$k8f$1@ger.gmane.org> <4B0C3BF8.1070904@redhat.com>
In-Reply-To: <4B0C3BF8.1070904@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peter Staubach wrote:
> At the end, does /mnt/foobar exist and contain the string, "baz"?
>   
I'll follow up with that information with that after the issue is next 
reproduced. (The mv operation is replacing a prior instance of 
/mnt/foobar, so content will need to be inspected to determine whether 
it was successful).

> What mount options are being used on the client?
>   
rw,vers=3,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=<redacted>
