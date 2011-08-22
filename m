From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: NFS client virtualization plan
Date: Mon, 22 Aug 2011 21:30:09 +0400
Message-ID: <4E529221.6010102@parallels.com>
References: <4E4A4DB1.2090105@parallels.com> <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com> <4E4E30E8.2080704@parallels.com> <CDCCBEC6-18B3-4ED5-A562-1DC4611F1169@oracle.com> <4E4E9B8C.8050000@parallels.com> <20110819193259.GC1641@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Pavel Emelianov <xemul@parallels.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15456 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496Ab1HVRab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 13:30:31 -0400
In-Reply-To: <20110819193259.GC1641@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.08.2011 23:32, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, Aug 19, 2011 at 09:21:16PM +0400, Stanislav Kinsbursky wrote:
>> Actually, yes, I do. Thanks for notice.
>> Kernel NSM monitor routines will be virtualized.
>> For idmapd and gssd rpc_pipefs virtualization is required.
>> I wasn't going to virtualize rpc_pipefs for now - it was planned to =
be a part of NFS server virtualization, which is planned to be done aft=
er NFS client virtualization.
>
> You'll need rpc_pipefs for gssd and the old idmapd.
>
> Also the new idmapper uses request_key.  I think there's a little
> discussion about this in the archives.
>

Thanks, Bruce.
Nice to know, that you noticed this discussion.
I'll rpc_pipefs to the todo list for NFS client.

--=20
Best regards,
Stanislav Kinsbursky
