Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51009 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab1DTJbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 05:31:42 -0400
Message-ID: <4DAEA860.8000203@cn.fujitsu.com>
Date: Wed, 20 Apr 2011 17:33:20 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>, iisaman@netapp.com
Subject: Re: [PATCH 1/5] CLNT: try to destroy session after test complete
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D904BEB.1060101@cn.fujitsu.com> <4D904D97.3020003@cn.fujitsu.com> <20110419152013.GB6316@fieldses.org>
In-Reply-To: <20110419152013.GB6316@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Mon, Mar 28, 2011 at 04:57:59PM +0800, Mi Jinlong wrote:
>> When testing pynfs41, I got NFS4ERR_DELAY at some tests.
>> At a test case, we don't destroy the session after create.
>> So, this patch try to destroy session test complete.
> 
> Sounds like a good idea.
> 
> It seems a little tedious to have to do this by hand every time; could
> we do some automatic cleanup at the end of the test when the variable
> goes out of scope, or something like that?

  I have try my best to find a automatic method to cleanup it,
  but I can't get.

  Maybe Fred can help us?


-- 
----
thanks
Mi Jinlong


