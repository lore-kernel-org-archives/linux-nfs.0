Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753199AbeC0QbC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 12:31:02 -0400
Date: Tue, 27 Mar 2018 12:31:02 -0400 (EDT)
From: Jianhong Yin <jiyin@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "Jianhong.Yin" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
Message-ID: <464328612.13844650.1522168262083.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180327162711.GA13526@parsley.fieldses.org>
References: <20180327064055.9559-1-yin-jianhong@163.com> <20180327162711.GA13526@parsley.fieldses.org>
Subject: Re: [PATCH] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- 原始邮件 -----
> 发件人: "J. Bruce Fields" <bfields@redhat.com>
> 收件人: "Jianhong.Yin" <yin-jianhong@163.com>
> 抄送: linux-nfs@vger.kernel.org, jiyin@redhat.com
> 发送时间: 星期三, 2018年 3 月 28日 上午 12:27:11
> 主题: Re: [PATCH] [pynfs] remove redundant ply, gssapi and rpcgen.py modules
> 
> Hm, I'm getting
> 
> Moving to nfs4.0
> Traceback (most recent call last):
>   File "./setup.py", line 16, in <module>
>     import use_local
> ImportError: No module named use_local
> 
> I guess that's due to this:
yes, need install xdr first.

they are copied from nfs4.1/setup.py, I will investigate what's use_local
> 
> On Tue, Mar 27, 2018 at 02:40:55PM +0800, Jianhong.Yin wrote:
> > diff --git a/nfs4.0/setup.py b/nfs4.0/setup.py
> > index f17a1c9..d5d3ad8 100755
> > --- a/nfs4.0/setup.py
> > +++ b/nfs4.0/setup.py
> > @@ -10,18 +10,20 @@ from distutils.core import setup, Extension
> >  from distutils.dep_util import newer_group
> >  import os
> >  import glob
> > +try:
> > +    import xdrgen
> > +except ImportError:
> > +    import use_local
> > +    import xdrgen
> 
> --b.
> 
