Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:29841 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758638AbZEZVxD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2009 17:53:03 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2385995ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2009 14:53:04 -0700 (PDT)
In-Reply-To: <392702.81064.qm@web43513.mail.sp1.yahoo.com>
References: <392702.81064.qm@web43513.mail.sp1.yahoo.com>
Date: Tue, 26 May 2009 17:53:04 -0400
Message-ID: <4d569c330905261453g59b4b878wb050bc8b2fcf838f@mail.gmail.com>
Subject: Re: Kerberos question related to NFSV3
From: Kevin Coffman <kwc@citi.umich.edu>
To: barry sabsevitz <barry_sabsevitz@yahoo.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 13, 2009 at 2:01 PM, barry sabsevitz
<barry_sabsevitz@yahoo.com> wrote:
>
> Hi,
> I have a question regarding NFSV3 and Kerberos that I was hoping someone could help me with.
>
> I have setup Kerberos successfully on a red hat 5.2 system using NFSV3. I am using nfs-utils-1.1.6
> and have a patch to rpc.svcgssd where I can specify a -h option and tell it to use a principal name that
> is different than the name of the system.
>
> My question is related to Kerberos and how it gets configured for NFS. I have a cluster with 2 nodes in
> it and each node can have multiple virtual ip addressess accessing NFS Kerberos shares from it. I have
> previously successfully setup a configuration where I create 1 service principal for every virtual IP address
> that will be processing the Kerberos NFSV3 exports. And then I modify DNS to have a forward and reverse
> mapping between the fqdn used for creating the service principal and the VIP.  This works for me. It seems
> a bit inefficient though.
>
>  My question is: Does Kerberos allow me to set up 1 service principal that can be used at the same time by
> multiple virtual ip addresses. For example: If I have 2 VIP's - 10.1.1.1 and 10.1.1.2, can I create 1 service
> principal called nfs/nfs-pkg1.activedir.net@ACTIVEDIR.NET and then have DNS configured to map
> nfs-pkg1 -> 10.1.1.1  and nfs-pkg1 also to -> 10.1.1.2 and then both those VIP's reverse mapped to
> nfs-pkg1. Is Kerberos with NFS expected to work in this configuration? Or do I need to have a seperate
> service principal for every virtual ip address that will be processing the Kerberos NFS exports?
>
> Thanks for your help.
> Barry

After some offline discussion, it sounds like Barry is possibly seeing
an issue with multiple DNS lookups during the mount process returning
different addresses for the name.  (Mostly speculation, but he is
seeing some kind of issue sharing a name between more than one
machine.)

I know people have worked on fail-over servers.  Has anyone else had a
cluster setup like this which uses the same name for more than one
machine, using Kerberos mounts?

K.C.
