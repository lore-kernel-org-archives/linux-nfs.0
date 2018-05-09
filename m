Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:35910 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935325AbeEIVTo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2018 17:19:44 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w49LBjsR054695
        for <linux-nfs@vger.kernel.org>; Wed, 9 May 2018 21:19:44 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2hv6m4gnf2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 09 May 2018 21:19:43 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w49LJhZ5024641
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 9 May 2018 21:19:43 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w49LJgP2017612
        for <linux-nfs@vger.kernel.org>; Wed, 9 May 2018 21:19:42 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: SETCLIENTID acceptor
Message-Id: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
Date: Wed, 9 May 2018 17:19:41 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm right on the edge of my understanding of how this all works.

I've re-keyed my NFS server. Now on my client, I'm seeing this on
vers=3D4.0,sec=3Dsys mounts:

May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred

manet is my client, and klimt is my server. I'm mounting with
NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.

Because the client is using krb5i for lease management, the server
is required to use krb5i for the callback channel (S 3.3.3 of RFC
7530).

After a SETCLIENTID, the client copies the acceptor from the GSS
context it set up, and uses that to check incoming callback
requests. I instrumented the client's SETCLIENTID proc, and I see
this:

check_gss_callback_principal: acceptor=3Dnfs@klimt.ib.1015granger.net, =
principal=3Dhost@klimt.1015granger.net

The principal strings are not equal, and that's why the client
believes the callback credential is bogus. Now I'm trying to
figure out whether it is the server's callback client or the
client's callback server that is misbehaving.

To me, the server's callback principal (host@klimt) seems like it
is correct. The client would identify as host@manet when making
calls to the server, for example, so I'd expect the server to
behave similarly when performing callbacks.

Can anyone shed more light on this?


--
Chuck Lever



