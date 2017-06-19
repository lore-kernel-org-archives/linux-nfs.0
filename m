Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36730 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbdFSTj0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jun 2017 15:39:26 -0400
Date: Mon, 19 Jun 2017 12:39:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Message-ID: <20170619193903.GA12803@infradead.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com>
 <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com>
 <20170615205357.GA13715@birch.djwong.org>
 <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 19, 2017 at 02:34:58PM -0400, Olga Kornievskaia wrote:
> Yes NFS community does need one for doing a server-to-server copy
> (performance) feature.

s/NFS community/NetApp/
