Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:40042 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758585Ab3DAPz0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2013 11:55:26 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 01 Apr 2013 11:55:24 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Vu, Joseph" <joseph.vu@boeing.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: RE: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
In-Reply-To: <756D04455A661C4CA25DC5BA4902A7A722698B22@XCH-PHX-204.sw.nos.boeing.com>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
 <20130328161444.GF7080@fieldses.org> <51550C03.1000107@davequigley.com>
 <20130329144050.GB22307@fieldses.org>
 <001ff69afd411b0318d7122bf07bd218@countercultured.net>
 <5155B0E3.9040108@schaufler-ca.com> <20130329184219.GG22307@fieldses.org>
 <5155F51E.8020603@schaufler-ca.com>
 <756D04455A661C4CA25DC5BA4902A7A722698B22@XCH-PHX-204.sw.nos.boeing.com>
Message-ID: <b226f82606306e86ffaede6909512e6d@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/01/2013 08:54, Vu, Joseph wrote:

> What is a good, and working alternative for NFS in term of SE label?

There isn't any unless you want to start a labeled cifs project. We 
looked at CIFS and NFSv4 back when I started this project and from what 
we saw NFS had the more open community. There are other solutions but 
they are not ideal. I believe someone did SELinux labels on network 
attached storage by treating the NAS as an iSCSI device. This isn't 
ideal because it has concurrency issues. Someone proposed xattr for 
NFSv4/NFSv3 support and that was shot down as well (and for good 
reason). I don't share Casey's skepticism about the long term importance 
of NFS. I think with NFSv4 and all the work that has gone into it we'll 
see NFS being important in Linux and enterprises for a very long time to 
come.

