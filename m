From: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Wed, 30 Jul 2008 21:20:02 +0200
Message-ID: <x6sktrfacd@gzp>
References: <20080729161512.7588.18445.stgit@manray.1015granger.net>
	<x6y73jyiek@gzp> <4890BA36.1060802@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:46215 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbYG3TUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 15:20:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Steve Dickson <SteveD@redhat.com>:

| > -lblkid doesn't enough in dependency, needs -luuid
| > 
| > Is this problem in my e2fsprogs install?
| At least in my world you also need the e2fsprogs-devel package
| installed as well...

libs and headers presents

| > Same apply on glibc 2.3.
| Note that sm-notify is a very short lived process.... 

| If have found using the -d flag is very handy when starting sm-notify 
| by hand... If there is no output, it means the /var/run/sm-notify.pid exists
| which causes sm-notify to immediately exit. So remove that file and try 
| again... 

Sure done that first. Attached strace output happens on fresh start.

| In general, if there are file(s) in /var/lib/nfs/sm (or /var/lib/nfs/statd/sm 
| depending on your distro) means sm-notify did not work. With Fedora, doing 
| a 'service nfslock restart' will cause sm-notify to be rerun... I'm not 
| sure how to do that with other distros... 

Those dirs are empty.
