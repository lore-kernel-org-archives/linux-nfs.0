Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mercury.cora.nwra.com ([4.28.99.165]:46072 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2LTVwp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2012 16:52:45 -0500
Message-ID: <50D388A9.9060300@cora.nwra.com>
Date: Thu, 20 Dec 2012 14:52:41 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and network
 is down
References: <loom.20121219T214634-616@post.gmane.org>   <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>   <50D236A4.6060906@cora.nwra.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA91196C146@SACEXCMBX04-PRD.hq.netapp.com>  <50D3758D.9060808@cora.nwra.com> <4FA345DA4F4AE44899BD2B03EEEC2FA91196FF19@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91196FF19@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/20/2012 01:47 PM, Myklebust, Trond wrote:
> On Thu, 2012-12-20 at 13:31 -0700, Orion Poplawski wrote:
>> On 12/19/2012 03:19 PM, Myklebust, Trond wrote:
>>>
>>> Commit eb96d5c97b0825d542e9c4ba5e0a22b519355166 (SUNRPC handle
>>> EKEYEXPIRED in call_refreshresult), which will be in 3.8-rc1 when Linus
>>> releases it, may help.
>>>
>>
>> FWIW - I cherry picked that into the latest Fedora rawhide kernel but no
>> effect.  Sounds like a nice patch though, the current hang forever behavior
>> doesn't seem the trigger the needed "ah, need a new ticket" response.
>>
> 
> So does simply killing the rpc.gssd process help?
> 

Yes, if automount is already stopped (these are automounted directories).  If
automount is running, it still seems to hang.  I think I'm going to need to
spend some time talking to Ian.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
