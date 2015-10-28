Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33143 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbJ1TdQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 15:33:16 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: GSSD warning with proto=rdma
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtREX8ZPw9eVaXpxaPSjmfjQvQpXcxS5DnOdjgq=zfthSg@mail.gmail.com>
Date: Wed, 28 Oct 2015 15:33:13 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <40E7CBBC-565F-41D7-BC3D-069FFD8B0BBB@oracle.com>
References: <216A83C3-D724-49C7-A64B-3471CF981AA3@oracle.com> <CAHQdGtREX8ZPw9eVaXpxaPSjmfjQvQpXcxS5DnOdjgq=zfthSg@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 28, 2015, at 3:30 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> On Wed, Oct 28, 2015 at 2:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi-
>> 
>> I’m beginning to try Kerberos with NFS/RDMA. I get this complaint
>> from GSSD:
>> 
>> Oct 28 13:10:02 manet rpc.gssd[2549]: WARNING: unrecognized
>> protocol, 'rdma', requested for connection to server
>> klimt-ib.1015granger.net for user with uid 0
>> 
>> Should I change the kernel NFS client to tell GSSD it’s using
>> TCP, or should I change GSSD to recognize RDMA as another form
>> of TCP?
>> 
> 
> gssd expects to be able to connect to the IP address that we pass in
> the upcall. If we can guarantee that IP address can always be resolved
> in a TCP connection attempt, then let's lie, and call it TCP.

NFS/RDMA still requires IPoIB to provide IP addresses that
resolve to GUIDs, so I think we can make that guarantee.

Still, do you prefer the kernel to lie, or for GSSD to lie?
Changing GSSD might be more future-proof.

—-
Chuck Lever



