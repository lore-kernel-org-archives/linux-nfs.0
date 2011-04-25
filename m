Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58822 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1DYP6f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 11:58:35 -0400
Subject: Re: [PATCH] svc: make sure mountd can get ports from /etc/services
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DB51E1B.5020004@cn.fujitsu.com>
Date: Mon, 25 Apr 2011 11:58:25 -0400
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Message-Id: <C34494E7-A0D3-428D-834B-FCAF473D056A@oracle.com>
References: <4DAD48C7.9090808@cn.fujitsu.com> <94B98C85-8FAE-4B72-A782-F0B0DFD83674@oracle.com> <4DAEA782.2090108@cn.fujitsu.com> <AD03EC99-CB5C-41BA-AE0B-FEA7A8D48B6E@oracle.com> <4DAFA7AB.9020507@cn.fujitsu.com> <5A8AD10C-81A4-4088-BCFA-08D0BA2337C7@oracle.com> <4DB51E1B.5020004@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 25, 2011, at 3:09 AM, Mi Jinlong wrote:

> Chuck Lever :
> 
>> In other words, we have a documented and supported mechanism now, that should always work, for setting mountd's listener port.  Can you explain in detail why allowing /etc/services to have this effect is also necessary?
> 
>  I just think the new nfs-utils should do the same thing as older one.
>  Maybe called backward compatibility.

I was confused by your original report.

Before, I read that with the commit mentioned above, /etc/services started working, then it stopped at some later point.  Now you seem to be saying that /etc/services always worked this way, but with the commit above, it stops working.  I've filed a bugzilla to track the issue:

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=200

If you can find documentation that describes this feature (ie makes it a formal API, or describes any other details about its operation we should know of), or know of a widely deployed application of mountd or statd that requires it, please do let us know, or modify the bugzilla report.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




