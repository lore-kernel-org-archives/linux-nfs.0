From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in NFSV3 ACCESS Procedure reply
Date: Thu, 28 Aug 2008 13:34:24 -0400
Message-ID: <20080828173424.GA3529@fieldses.org>
References: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Dilip Kumar <udilipkumar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbYH1Re0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 13:34:26 -0400
In-Reply-To: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2008 at 12:41:34PM -0700, Dilip Kumar wrote:
> Hi all,
> 
> I noticed a bug in the access rights of a NFSV3 ACCESS Reply. If a
> directory was created with only write permissions for the owner (chmod
> 200 directory), we expect the modify, extend and delete bits (access =
> 0x1C) to be set for this directory in the reply to an ACCESS RPC call
> with access = 0x1F send by the owner. Instead the NFS server on Linux
> returns an ACCESS Reply with access set to 0x0 (none of the bits were
> set). I tried checking this against Solaris server and it returns the
> expected access rights 0x1C. The Linux server I was using for testing
> was 2.6.9-1.667smp and the Solaris server was SunOS 5.8
> Generic_108528-22 Ultra Sparc-IIi.

What user are you performing the access call as, and who owns the
directory?  What does exportfs -v say?   (Do you have root_squash or
no_root_squash set?)

--b.

> 
> Please let me know if you need further details regarding this issue.
> 
> Thanks
> Dilip Kumar
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
