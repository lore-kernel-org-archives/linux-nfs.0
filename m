Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33188 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755404AbcHSVLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 17:11:44 -0400
Date: Fri, 19 Aug 2016 17:11:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trondmy.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version-2 04/12] NFS inter ssc open
Message-ID: <20160819211143.GS32329@fieldses.org>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
 <1471627512-4102-5-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1471627512-4102-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2016 at 01:25:04PM -0400, andros@netapp.com wrote:
> +struct nfs42_inter_ssc {
> +	struct vfsmount	*sc_root_mnt;
> +	struct dentry	*sc_mnt_dentry;
> +};

That's just reinventing struct path.

--b.
