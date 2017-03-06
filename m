Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39088 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932086AbdCFTXE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Mar 2017 14:23:04 -0500
Date: Mon, 6 Mar 2017 14:23:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-man@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Olga Kornievskaia <kolga@netapp.com>
Subject: Re: [RFC v1 01/19] Don't copy beyond the end of the file
Message-ID: <20170306192301.GB2294@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
 <20170303213230.GF13877@fieldses.org>
 <B3F80DA0-B4F8-4628-88C5-E5C047620F17@netapp.com>
 <20170304021008.GB21609@fieldses.org>
 <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 06, 2017 at 11:27:23AM -0500, Olga Kornievskaia wrote:
> I don’t see copy_file_range() specifying that 0 means end of the file.

Is there a reason that copy_file_range shouldn't be like read?  (From
read(2): "On  success,  the number of bytes read is returned (zero
indicates end of file)".

I haven't checked, but suspect that's already true of the
implementations we have.

Also, from copy_file_range():

	EINVAL Requested  range  extends beyond the end of the source
		file; or the flags argument is not 0.

Some filesystems do this, some don't; I think the man page should make
it clear that this behavior is not required.

--b.
