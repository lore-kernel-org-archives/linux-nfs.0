Return-Path: <dros@primarydata.com>
From: Weston Andros Adamson <dros@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
CC: Alexey Dobriyan <adobriyan@gmail.com>,
        linux-nfs list
	<linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "Anna
 Schumaker" <anna.schumaker@netapp.com>
Subject: Re: [PATCH] nfs: don't create zero-length requests
Date: Mon, 18 Jul 2016 17:39:47 +0000
Message-ID: <AEF1FA26-36FE-49D2-B4C4-F2462962C56A@primarydata.com>
References: <9a3042bc347cd708966dbba03b14302b4819c1d1.1468852483.git.bcodding@redhat.com>
 <20160718172444.GA2779@p183.telecom.by>
In-Reply-To: <20160718172444.GA2779@p183.telecom.by>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 18, 2016, at 1:24 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>=20
> On Mon, Jul 18, 2016 at 10:41:57AM -0400, Benjamin Coddington wrote:
>> NFS doesn't expect requests with wb_bytes set to zero and may make
>> unexpected decisions about how to handle that request at the page IO lay=
er.
>> Skip request creation if we won't have any wb_bytes in the request.
>>=20
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Reviewed-by: Weston Andros Adamson <dros@primarydata.com>

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
