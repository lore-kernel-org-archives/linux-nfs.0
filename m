Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:33237 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095Ab1JSUIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:08:25 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RGcR6-00085F-Ms
	for linux-nfs@vger.kernel.org; Wed, 19 Oct 2011 22:08:24 +0200
Received: from ebox.rath.org ([173.255.235.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 22:08:24 +0200
Received: from Nikolaus by ebox.rath.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 22:08:24 +0200
To: linux-nfs@vger.kernel.org
From: Nikolaus Rath <Nikolaus@rath.org>
Subject: Re: Does NFS4 need st_gen?
Date: Wed, 19 Oct 2011 15:11:27 -0400
Message-ID: <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
	<20111019171551.GA32028@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:
> On Wed, Oct 19, 2011 at 10:17:43AM -0400, Nikolaus Rath wrote:
>> Does NFS4 still depend on inode generation numbers? I understand that
>> earlier NFS versions used file handles based on inode and generation
>> number, but it seems to me that this shouldn't be required anymore with
>> the (stateful) NFS4.
>
> Yes, it's true that NFSv4 has open and close operations, but filehandles
> are still used a great deal outside of that, and clients are still
> allowed to assume that the same filehandle always refers to the same
> object.
>
> http://www.ietf.org/rfc/rfc3530.txt, section 4.2.1:
>
> 	"If two filehandles from the same server are equal, they MUST
> 	refer to the same file."

Duh - that's a disappointment. Thanks for the pointer!

Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C

