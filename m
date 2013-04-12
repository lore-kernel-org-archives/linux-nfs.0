Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875Ab3DLTFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 15:05:13 -0400
Message-ID: <51685AE6.8080207@RedHat.com>
Date: Fri, 12 Apr 2013 15:05:10 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: No longer negotiate to v2
References: <1365782736-9764-1-git-send-email-steved@redhat.com> <1365782736-9764-2-git-send-email-steved@redhat.com> <2A4E5E3D-FCC3-4E16-80CA-77E079EF860F@oracle.com>
In-Reply-To: <2A4E5E3D-FCC3-4E16-80CA-77E079EF860F@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/04/13 13:00, Chuck Lever wrote:
> On Apr 12, 2013, at 12:05 PM, Steve Dickson <steved@redhat.com> wrote:
> 
>> > This patch remove the ability of negotiating to the v2
>> > protocol. Explicitly setting the version on the command
>> > line will be the only way to use v2.
> Just curious: is there a way to do this using the mount configuration file?
No. One can set the Nfsvers=2 for legacy servers if need be, but there is no
mount option that controls the how the protocols are negotiated.

steved.

