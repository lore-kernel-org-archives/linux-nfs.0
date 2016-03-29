Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:35163 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbcC2WhB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2016 18:37:01 -0400
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Arend van Spriel <arend.vanspriel@broadcom.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [REGRESSION 4.6-rc1] NFS mounts (using autofs) failing
Date: Tue, 29 Mar 2016 22:36:05 +0000
Message-ID: <56FB0355.2030506@ce.jp.nec.com>
References: <56FA62FB.1080506@broadcom.com>
 <20160329140244.GV17997@ZenIV.linux.org.uk> <56FAD4B4.3070508@broadcom.com>
In-Reply-To: <56FAD4B4.3070508@broadcom.com>
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/16 04:17, Arend van Spriel wrote:
> On 29-03-16 16:02, Al Viro wrote:
>> On Tue, Mar 29, 2016 at 01:11:55PM +0200, Arend Van Spriel wrote:
>>> Moved to 4.6-rc1 and found NFS mounts were failing moving to the new
>>> kernel. The NFS mounts are done using autofs. Below is the bisect log
>>> and attached the kernel .config file. Let me know if you need any other
>>> information.
>>
>> AFAICS, it's the same one that got reported yesterday by Junichi Nomura.
>> Folks, could you check if the delta below fixes it?
> 
> Works for me so you may add
> 
> Tested-by: Arend van Spriel <arend@broadcom.com>

Yes, that works for me, too. Thank you.

Tested-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

-- 
Jun'ichi Nomura, NEC Corporation
