From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 18:34:57 +0200
Message-ID: <20080425163457.GA6952@uio.no>
References: <20080425080535.GA4999@uio.no> <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:60786 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757AbYDYQfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 12:35:01 -0400
In-Reply-To: <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 12:20:19PM -0400, Chuck Lever wrote:
>> It seems retry= is now additive with the text-based mount interface.  In
>> particular, "mount -o retry=0" still gives a two-minute timeout. Is  this
>> intentional?
> No, it's broken.  Can you test the attached patch?

It seems it creates rather odd behavior:


fugl:~# mount -t nfs -v -o retry=0 10.0.0.11:/foo /mnt
mount.nfs: timeout set for Thu Jan  1 14:40:25 1970
mount.nfs: text-based options: 'retry=0,addr=10.0.0.11'

fugl:~# mount -t nfs -v -o retry=0 10.0.0.11:/foo /mnt
mount.nfs: timeout set for Sat Jan 10 17:07:36 1970
mount.nfs: text-based options: 'retry=0,addr=10.0.0.11'

/* Steinar */
-- 
Homepage: http://www.sesse.net/
