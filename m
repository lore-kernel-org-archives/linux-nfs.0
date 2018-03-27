Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57540 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbeC0Sh0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 14:37:26 -0400
Date: Tue, 27 Mar 2018 14:37:25 -0400
To: "Jianhong.Yin" <yin-jianhong@163.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Jianhong Yin <jiyin@redhat.com>
Subject: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
Message-ID: <20180327183725.GA22077@fieldses.org>
References: <20180327172709.13071-1-yin-jianhong@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180327172709.13071-1-yin-jianhong@163.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 01:27:08AM +0800, Jianhong.Yin wrote:
> +Install dependent modules:
> +	#Fedora: yum install krb5-devel python-devel swig python-pip
> +	#Debian: apt-get install libkrb5-dev python-dev swig python-pip
> +	pip install ply gssapi

I've never used pip.  Googling around, I see some people warn about
potential conflicts between pip and rpm/dpkg.  Would it be better to
recommend pip install --user?

Anyway, looks better than carrying our own copy around.  Applying,
thanks!

--b.
