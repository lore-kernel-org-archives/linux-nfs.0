Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa9.utexas.iphmx.com ([216.71.150.155]:46498 "EHLO
        esa9.utexas.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbeC0Tdd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 15:33:33 -0400
Subject: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Jianhong.Yin" <yin-jianhong@163.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Jianhong Yin <jiyin@redhat.com>
References: <20180327172709.13071-1-yin-jianhong@163.com>
 <20180327183725.GA22077@fieldses.org>
From: Patrick Goetz <pgoetz@math.utexas.edu>
Message-ID: <fc72ad79-c558-f6bb-fa96-870ba522a427@math.utexas.edu>
Date: Tue, 27 Mar 2018 14:24:00 -0500
MIME-Version: 1.0
In-Reply-To: <20180327183725.GA22077@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2018 01:37 PM, J. Bruce Fields wrote:
> I've never used pip.  Googling around, I see some people warn about
> potential conflicts between pip and rpm/dpkg.  Would it be better to
> recommend pip install --user?
> 


Pip is just the python package installer, similar to install.packages() 
in R or cpan in perl.

The issue with rpm/dpkg/pacman is that the distribution package manager 
won't know about anything that you've installed using pip, which could 
mean, for example, that you've met a library dependency using pip, but 
apt or yum insist that the library is missing and needs to be installed.



