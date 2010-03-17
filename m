From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] Two short fixes for sm-notify
Date: Wed, 17 Mar 2010 10:29:07 -0400
Message-ID: <4BA0E733.4040002@oracle.com>
References: <20100315174453.2586.40876.stgit@localhost.localdomain> <4BA0B48E.8030504@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50755 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab0CQObX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 10:31:23 -0400
In-Reply-To: <4BA0B48E.8030504-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2010 06:53 AM, Steve Dickson wrote:
>
>
> On 03/15/2010 01:51 PM, Chuck Lever wrote:
>> Hi Steve-
>>
>> These address two minor shortcomings when sending SM_NOTIFY requests
>> during reboot recovery.  Please consider these for the next nfs-utils
>> release.
>>
> Just curious... Where these the outcome of reported problem or was this
> something you happen to notice.

These are recommendations from Tom Talpey's Connectathon talk a few 
years back.  A few other implementations already do similar things.

-- 
chuck[dot]lever[at]oracle[dot]com
