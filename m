Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33376 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab1G0QRS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 12:17:18 -0400
Received: by vws1 with SMTP id 1so1226773vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2011 09:17:17 -0700 (PDT)
Message-ID: <4E303A09.10906@marcanoonline.com>
Date: Wed, 27 Jul 2011 11:47:13 -0430
From: Robert Marcano <robert@marcanoonline.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug?
References: <4E2ED2A0.4030401@marcanoonline.com> <20110727154736.GB974@fieldses.org>
In-Reply-To: <20110727154736.GB974@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 11:17 AM, J. Bruce Fields wrote:
> On Tue, Jul 26, 2011 at 10:13:44AM -0430, Robert Marcano wrote:
...
>> Is this normal or a bug?, My interpretation is that even that the
>> mapping of the ACLs is not 100% perfect this simple example should
>> not be a problem. Is it impossible using NFS to create a shared
>> directory for a group of users?
>
> Without looking at your example carefully, it sounds like the same
> problem as discussed here:
>
> 	http://marc.info/?t=123739823200003&r=1&w=2

Thanks, exactly the same problem, current user umask getting in the way 
of ACL inheritance, looks like the answers is that this is currently not 
possible because the umask is applied client side and the NFSv4 protocol 
does not help to send that info to the server. No workaround available 
(mount option or something like that)
