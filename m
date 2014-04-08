Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:51640 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756856AbaDHRaY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2014 13:30:24 -0400
Received: by mail-ig0-f177.google.com with SMTP id ur14so1339397igb.16
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2014 10:30:24 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: v4.0 CB_COMPOUND authentication failures
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140408164024.GH3882@fieldses.org>
Date: Tue, 8 Apr 2014 13:30:21 -0400
Cc: Layton Jeff <jlayton@redhat.com>, NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
Message-Id: <8F132114-F44C-449B-8EA8-331C67FCE813@primarydata.com>
References: <20140408082140.340c1328@tlielax.poochiereds.net> <20140408123501.GA3532@fieldses.org> <20140408094903.33e42de2@tlielax.poochiereds.net> <20140408140333.GD3882@fieldses.org> <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com> <20140408144652.GE3882@fieldses.org> <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com> <20140408164024.GH3882@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 8, 2014, at 12:40, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> 
> On Tue, Apr 08, 2014 at 12:22:51PM -0400, Trond Myklebust wrote:
>> How is it not better just to rip out that hostname comparison in the
>> back channel?
> 
> Rip it out entirely?
> 
> At that point anyone who can get a credential in the right realm can
> send a recall.  RFC made this requirement to prevent that.
> 

OK. Let’s examine what RFC3530 and RFC3530bis actually says here:

   Regardless of what security mechanism under RPCSEC_GSS is being used,
   the NFS server MUST identify itself in GSS-API via a
   GSS_C_NT_HOSTBASED_SERVICE name type.  GSS_C_NT_HOSTBASED_SERVICE
   names are of the form:

     service@hostname

   For NFS, the "service" element is

     nfs

   Implementations of security mechanisms will convert nfs@hostname to
   various different forms.  For Kerberos V5, the following form is
   RECOMMENDED:

   nfs/hostname

   For Kerberos V5, nfs/hostname would be a server principal in the
   Kerberos Key Distribution Center database.  This is the same
   principal the client acquired a GSS-API context for when it issued
   the SETCLIENTID operation, therefore, the realm name for the server
   principal must be the same for the callback as it was for the
   SETCLIENTID.


So as I read the above, technically the client is supposed to read off the principal name that the server uses to authenticate itself to the SETCLIENTID and check that in the callback. Am I wrong?

If so, then the steps are:

1) Modify process_krb5_upcall() and have the call to gss_inquire_context() also request the context acceptor name
2) Modify the rpc.gssd downcall to pass that name to the kernel in some format that allow us to retrieve it in the SETCLIENTID call.
3) Modify the comparison in check_gss_callback_principal()


_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

