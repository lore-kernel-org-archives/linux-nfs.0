From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 17:37:27 +0100
Message-ID: <20081112163727.GA31625@uio.no>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no> <491AFEB9.1090208@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:51512 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbYKLQhf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:37:35 -0500
In-Reply-To: <491AFEB9.1090208@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 05:05:13PM +0100, Le Rouzic wrote:
> There is a prototype nfs-utils package based on nfs-utils-1.1.2 you can  
> play with at http://nfsv4.bullopensource.org/

I already tried that with the latest git tree from Chuck, but no go
(statd/nfsd didn't register on IPv6 in rpcbind, IIRC).

/* Steinar */
-- 
Homepage: http://www.sesse.net/
