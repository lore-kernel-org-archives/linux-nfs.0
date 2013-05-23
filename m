Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:55626 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876Ab3EWOUV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 May 2013 10:20:21 -0400
Date: Thu, 23 May 2013 10:20:10 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Yong, Fan" <fan.yong@intel.com>, Peng Tao <bergwolf@gmail.com>,
        "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Message-ID: <20130523142010.GA3634@umich.edu>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
 <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
 <1369313382.3764.2.camel@leira.trondhjem.org>
 <7FB055E0B36B6F4EB93E637E0640A56F5B4AA961@FMSMSX114.amr.corp.intel.com>
 <1369316375.3764.7.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1369316375.3764.7.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  On Thu, 2013-05-23 at 12:59 +0000, Yong, Fan wrote:
  > Just make it match the "inode64" in nfs-utils parse_fsid(), which is defined as "unsigned long long", and the parsed_fsid:: inode is copied from "inode64" as following:
  > 
  > static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
  >                 struct parsed_fsid *parsed)
  > {
  >         unsigned int dev;
  >         unsigned long long inode64;
  > ...
  >         case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
  >                 if (fsidlen != 24)
  >                         return -1;
  >                 memcpy(&inode64, fsid, 8);
  >                 parsed->inode = inode64;
  >                 parsed->uuidlen = 16;
  >                 parsed->fhuuid = fsid+8;
  >                 break;
  >         }
  > 
  > --
  > Cheers,
  > Nasf
  
  Eeeeeeeewww! This is _exactly_ why we should be using properly
  dimensioned types. Feel free to tell me how the value of 'inode64' is
  well defined on systems where sizeof(unsigned long long) != 8...

Is there any reason not to use ino_t?
