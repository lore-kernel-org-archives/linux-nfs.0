From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH_V7 0/12] NFSv4 find client fix Version 7
Date: Tue, 4 Jan 2011 17:12:58 -0500
Message-ID: <9D7DA229-428E-4F20-83AE-A5CEA5D39A7B@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com> <20110104205713.GA7908@fieldses.org> <EF4E9447-046D-4840-B7F1-5D5391A97F67@netapp.com> <20110104210637.GD7908@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, bfields@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58952 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967Ab1ADWNA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 17:13:00 -0500
In-Reply-To: <20110104210637.GD7908@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2011, at 4:06 PM, J. Bruce Fields wrote:

> On Tue, Jan 04, 2011 at 04:01:16PM -0500, Andy Adamson wrote:
>> 
>> On Jan 4, 2011, at 3:57 PM, J. Bruce Fields wrote:
>> 
>>> On Tue, Jan 04, 2011 at 03:42:34PM -0500, andros@netapp.com wrote:
>>>> 
>>>> 
>>>> Version 7 of these patches
>>>> Applies to Tronds nfs-for-next branch
>>>> 
>>>> Already acked by bfields
>>>> ------------------------
>>>> 0001-SUNRPC-move-svc_drop-to-caller-of-svc_process_common.patch
>>>> 0002-SUNRPC-fix-bc_send-print.patch
>>>> 0010-NFS-RPC_AUTH_GSS-unsupported-on-v4.1-back-channel.patch
>>>> 0012-NFS-rename-client-back-channel-transport-field.patch
>>> 
>>> In future, if you don't mind actually adding the "Acked-by"'s to those
>>> patches with your signed-off-by's, that'll help remind me which ones
>>> I've read before as I'm looking through them....
>>> 
>>> (Well, unless you've changed them in some non-trivial way and want me to
>>> reread them.)
>> 
>> Sure.
>> 
>> -->Andy
> 
> And thanks for the fast turnaround.  I think that's it for my comments.

Thank you as well for your reviews and quick turn around.  You may want to look at the patch in the next series that registers the back channel transport in the rpc layer.

-->Andy

> 
> --b.

