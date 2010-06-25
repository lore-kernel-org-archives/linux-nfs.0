From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH] sunrpc: split the vs_hidden flag into TCP and UDP
 variants
Date: Fri, 25 Jun 2010 09:14:10 -0400
Message-ID: <1277471650.2881.6.camel@heimdal.trondhjem.org>
References: <1277429621-9579-1-git-send-email-jlayton@redhat.com>
	 <BF3BB6D12298F54B89C8DCC1E4073D800183CAB2@CORPUSMX50A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: jlayton@redhat.com, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Staubach_Peter@emc.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43104 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755547Ab0FYNOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 09:14:20 -0400
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D800183CAB2-1Zg0zMUlrbd9m/dOYFj4Yjjd7nCn89gW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-06-25 at 08:58 -0400, Staubach_Peter@emc.com wrote:
> Does this mean that the Linux NFS server will no longer respond to NFSv4
> requests coming in over UDP?  If it will continue to do so, wouldn't it
> be more important to solve that correctly?

Agreed. Either we keep UDP support on the server and advertise it too,
or we should throw it out altogether...

Cheers
  Trond

