From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 8 Dec 2008 16:02:19 +0100
Message-ID: <20081208150219.GB12390@uio.no>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:32906 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbYLHPDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 10:03:44 -0500
In-Reply-To: <493D253C.2040809-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 08, 2008 at 08:46:36AM -0500, Steve Dickson wrote:
> typedef struct {
>     char **hostname;
>     struct sockaddr_in saddr;
>     struct pmap pmap; 
> } clnt_addr_t;
> 
> Why isn't saddr a struct sockaddr instead of a struct sockaddr_in?
> 
> It seems at the beginning of each routine saddr is always being
> typecast into a struct sockaddr pointer.... So wouldn't be easier
> and cleaner to simply make sadd a struct sockaddr or am I missing
> something?

I'm sure most people here know this, but still, be careful: If you ever
intend to store an IPv6 address somewhere, the field in the struct should be
a sockaddr_storage. sockaddr (or sockaddr_in, for that matter) is not big
enough to store a sockaddr_in6.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
