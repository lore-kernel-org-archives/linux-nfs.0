From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: FAQ: Updating shared executables
Date: Tue, 9 Dec 2008 17:44:45 -0500
Message-ID: <20081209224445.GA12335@fieldses.org>
References: <ghm8pm$d6c$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeremy Sanders <jeremy-rZTbbJwr4dtS98Db7trcLl6hYfS7NtTn@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45646 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754683AbYLIWor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 17:44:47 -0500
In-Reply-To: <ghm8pm$d6c$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2008 at 05:10:14PM +0000, Jeremy Sanders wrote:
> Hi - I notice the FAQ says that the crashes caused by updating shared
> libraries on NFS partitions are due to cash consistency rules (FAQ D9).
> Does NFSv4 fix this issue?

No, you still need the workaround described there:

	http://nfs.sourceforge.net/#faq_d9

	"The correct way to update executables and shared libraries on
	your NFS shares is to use the install program with the '-b'
	option. That renames the version of the executable that is in
	use, then creates a brand new file to contain the new version of
	the executable."

--b.
