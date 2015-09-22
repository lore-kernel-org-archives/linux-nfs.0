Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47449 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbbIVLsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 07:48:08 -0400
Date: Tue, 22 Sep 2015 13:47:12 +0200
From: David Sterba <dsterba@suse.cz>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v2 4/9] vfs: Copy should check len after file open mode
Message-ID: <20150922114712.GG8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442003423-6884-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 04:30:17PM -0400, Anna Schumaker wrote:
> I don't think it makes sense to report that a copy succeeded if the
> files aren't open properly.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Reviewed-by: David Sterba <dsterba@suse.com>
