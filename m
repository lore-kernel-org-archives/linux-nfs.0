Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60652 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752279AbeC0XOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 19:14:07 -0400
Date: Tue, 27 Mar 2018 19:14:07 -0400 (EDT)
From: Jianhong Yin <jiyin@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Jianhong.Yin" <yin-jianhong@163.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Message-ID: <1764206678.13920688.1522192447032.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180327183725.GA22077@fieldses.org>
References: <20180327172709.13071-1-yin-jianhong@163.com> <20180327183725.GA22077@fieldses.org>
Subject: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good to know.
will update README to inform users: they could use any/different methods to install these modules.

Thanks!

----- 原始邮件 -----
> 发件人: "J. Bruce Fields" <bfields@fieldses.org>
> 收件人: "Jianhong.Yin" <yin-jianhong@163.com>
> 抄送: bfields@redhat.com, linux-nfs@vger.kernel.org, "Jianhong Yin" <jiyin@redhat.com>
> 发送时间: 星期三, 2018年 3 月 28日 上午 2:37:25
> 主题: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py modules
> 
> On Wed, Mar 28, 2018 at 01:27:08AM +0800, Jianhong.Yin wrote:
> > +Install dependent modules:
> > +	#Fedora: yum install krb5-devel python-devel swig python-pip
> > +	#Debian: apt-get install libkrb5-dev python-dev swig python-pip
> > +	pip install ply gssapi
> 
> I've never used pip.  Googling around, I see some people warn about
> potential conflicts between pip and rpm/dpkg.  Would it be better to
> recommend pip install --user?
> 
> Anyway, looks better than carrying our own copy around.  Applying,
> thanks!
> 
> --b.
> 
