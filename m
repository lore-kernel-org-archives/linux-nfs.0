Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:51969 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753842Ab2BPULB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 15:11:01 -0500
Date: Thu, 16 Feb 2012 15:10:56 -0500
From: Jim Rees <rees@umich.edu>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Send implementation id with exchange_id
Message-ID: <20120216201056.GA29946@umich.edu>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
 <20120216173022.GA29158@umich.edu>
 <A63ABD4E-F7EA-4B7A-9866-D22363F216F8@netapp.com>
 <6174C8A1-D1C7-4D26-97A1-1D983FA1D5F4@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6174C8A1-D1C7-4D26-97A1-1D983FA1D5F4@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adamson, Dros wrote:

  >> General comment... If this is going to be configurable, I'd rather make it a
  >> sysctl, and be able to set the id to whatever I want at run time.  But
  >> that's because I like to be able to break things.  I suspect Trond will
  >> disagree.
  > 
  > Hrm my ispell pass missed this.
  
  … I'll wait for additional comments before reposting.

I guess my point was, why make it configurable at all?
