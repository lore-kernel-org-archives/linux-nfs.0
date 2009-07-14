From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: Security negotiation
Date: Tue, 14 Jul 2009 13:24:24 -0500
Message-ID: <4A5CCD58.7080001@excfb.com>
References: <4A578372.1020005@excfb.com> <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com> <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com> <4A57AADE.8080002@excfb.com> <20090713174136.GA20884@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao105.cox.net ([68.230.240.47]:46558 "EHLO
	eastrmmtao105.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbZGNSYa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 14:24:30 -0400
In-Reply-To: <20090713174136.GA20884@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> Yeah, that was a linux mountd bug.  Fixed by the below.  And note the
> rfc language it mentions:
>
> 	"For this reason, a NFS client SHOULD use the first flavor in the
> 	list that it supports, on the assumption that the best access is
> 	provided by the first flavor. NFS servers that support the
> 	ability to export file systems with multiple security flavors
> 	SHOULD either present the best accessing flavor first to the
> 	client, or leave the order under the control of the system
> 	administrator."
>
> Of course we may still be stuck with buggy servers, so perhaps a careful
> client will still want to handle auth_null at least specially....
>
>   

Hey Chuck and Bruce,

Thanks for the discussion on this subject, it really helped us by 
understanding what the
Linux client and server was doing.

Tom
