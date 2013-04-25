Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:3052 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756119Ab3DYP2h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Apr 2013 11:28:37 -0400
Date: Thu, 25 Apr 2013 11:28:21 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, bfields@fieldses.org
Message-ID: <916743278.65.1366903701195.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1366899034.6812.4.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for Ni
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Just to clarify, the IBM delay behavior is not legal?

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> 
> OK, then. Now all I need is actual motivation for changing the
> existing
> code other than handwaving arguments about "polling is better than
> flat
> waits".
> What actual use cases are impacting us now, other than the AIX design
> decision to force CLOSE to retry at least once before succeeding?
> 


-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
