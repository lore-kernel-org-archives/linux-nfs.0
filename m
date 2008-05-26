From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Mon, 26 May 2008 10:44:07 +0200
Message-ID: <9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <20080519144806.GB7622@fieldses.org>
	 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	 <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:11222 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbYEZIoJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 May 2008 04:44:09 -0400
Received: by nf-out-0910.google.com with SMTP id d3so854478nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 26 May 2008 01:44:07 -0700 (PDT)
In-Reply-To: <RTPCLUEXC1-PRDRXf2L00000168-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2008 at 9:08 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
>> The main thing here is that I'd like to understand why this is
>>happening? What does it mean when ls returns something like:
>>
>>d????????? ? ?        ?          ?                ? cur
>
> This is something very different. (I'm assuming this "ls" was done on the
> NFS mount and not the server itself.)

Yes, ls on the NFS mount on the client.

> Usually, this happens because there
> are no attributes available locally - ls seems to know only the filetype
> (directory) and filename (cur). What client kernel version are you running?

Client kernel: 2.6.24.4-64.fc8
Server kernel: 2.6.9-1.667

-- 
Alex Borghgraef
