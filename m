From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Tue, 9 Dec 2008 00:28:16 +0100
Message-ID: <20081208232816.GA18856@uio.no>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com> <493DA5EC.5090805@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:55872 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261AbYLHX2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 18:28:25 -0500
In-Reply-To: <493DA5EC.5090805-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 08, 2008 at 05:55:40PM -0500, Steve Dickson wrote:
> Yes... one does pass pointers of struct sockaddr to the majority 
> of the network system call such as bind().. but conventionally 
> I've seen a lot of declare struct sockaddr as memory then typecasting 
> that memory into a struct sockaddr_in pointer...

That's just wrong. Don't do that :-) (Where have you seen this, by the way?)

/* Steinar */
-- 
Homepage: http://www.sesse.net/
