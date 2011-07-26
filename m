Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40809 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663Ab1GZTd5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 15:33:57 -0400
Received: by qyk29 with SMTP id 29so1691670qyk.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 12:33:56 -0700 (PDT)
Message-ID: <4E2F16A0.80105@marcanoonline.com>
Date: Tue, 26 Jul 2011 15:03:52 -0430
From: Robert Marcano <robert@marcanoonline.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug?
References: <4E2ED2A0.4030401@marcanoonline.com> <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com> <4E2F1584.60901@marcanoonline.com>
In-Reply-To: <4E2F1584.60901@marcanoonline.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/26/2011 02:59 PM, Robert Marcano wrote:
> On 07/26/2011 02:03 PM, Andy Adamson wrote:
>> Hi
>>
>> Which client, which server (distro and uname -a output) did you use?
>> Also, what commands (setfacl,getfacl? nfs4_setfacl, nfs4_getfacl ?
>> plus version) and parameters did you use?

Adding missing versions on the CentOS NFS Server

setfacl 2.2.39
getfacl 2.2.39

