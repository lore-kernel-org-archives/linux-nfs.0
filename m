Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:39790 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751777AbeFAQMB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 12:12:01 -0400
Received: by mail-it0-f52.google.com with SMTP id c3-v6so2444408itj.4
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2018 09:12:01 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: RPC UDP message size limit
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <726a7d92-bcb0-6120-252c-26d3a0951ddc@tudelft.nl>
Date: Fri, 1 Jun 2018 12:11:59 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4A3758CC-06B1-4F7D-B05E-5D9AA9E32C7C@gmail.com>
References: <726a7d92-bcb0-6120-252c-26d3a0951ddc@tudelft.nl>
To: Robbert Eggermont <R.Eggermont@tudelft.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 1, 2018, at 8:07 AM, Robbert Eggermont <R.Eggermont@tudelft.nl> =
wrote:
>=20
> Recently we started hitting the libtirpc RPC UDP message size limit =
(tirpc/rpc/rpc.h: #define UDPMSGSIZE 8800) for 'showmount -e' from a =
NetApp filer (with around 25kB worth of exports). Only 8800 bytes are =
read, resulting in an abort with a "rpc mount export: RPC: Can't decode =
result" error.

8KB seems to be a documented limit for UDP. =46rom "man clnt_create":

     CLIENT *
     clnt_create(char *host, u_long prog, u_long vers, char *proto)

             Generic client creation routine.  The host argument =
identifies the name of the remote host where the server is located.  The
             proto argument indicates which kind of transport protocol =
to use.  The currently supported values for this field are "udp" and
             "tcp".  Default timeouts are set, but can be modified using =
clnt_control().

             Warning: Using UDP has its shortcomings.  Since UDP-based =
RPC messages can only hold up to 8 Kbytes of encoded data, this
             transport cannot be used for procedures that take large =
arguments or return huge results.

A larger message size limit would not be safe for all RPC protocols
that use UDP.


> Since it seems filers are already using a higher limit, should this =
limit be increased (at least for receiving, which should be safe)?

=46rom utils/showmount/showmount.c

107         client =3D clnt_create(hostname, program, vers, "tcp");
108         if (client)
109                 return client;
110         client =3D clnt_create(hostname, program, vers, "udp");
111         if (client)
112                 return client;

IIUC showmount could use the clnt_{vc,dg}_create(3) APIs instead of
the generic clnt_create(3) API to specify a larger message size limit.

However, using TCP would immediately work around the UDP message size
limit. But perhaps the filer is not allowing a TCP connection for the
MNT service?


--
Chuck Lever
chucklever@gmail.com



