Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:47102 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab1CQRw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 13:52:59 -0400
Date: Thu, 17 Mar 2011 13:52:56 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Kevin Constantine <Kevin.Constantine@disneyanimation.com>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS hanging waiting for a process to be killable?
Message-ID: <20110317175256.GA2730@merit.edu>
References: <4D80F8B9.1080900@disney.com>
 <4D823B81.5040702@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D823B81.5040702@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  I wonder if this is the same problem Jim was seeing a while back
  as well as some other people.... Something similar to:
      https://bugzilla.redhat.com/show_bug.cgi?id=669204

I wondered that too.  The traces are hard to read (someone word-wrapped
them) but they looked different to me.  Could be the same underlying
problem.
