Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160Ab2EAS7Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 14:59:16 -0400
Message-ID: <4FA03090.1090605@RedHat.com>
Date: Tue, 01 May 2012 14:50:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 4/4] osd_login: Add autologin script for objlayoutdriver
References: <4F62DADD.3010502@panasas.com> <4F62DD6C.4040504@panasas.com>
In-Reply-To: <4F62DD6C.4040504@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/16/2012 02:27 AM, Boaz Harrosh wrote:
> From: Sachin Bhamare <sbhamare@panasas.com>
> 
> This script is part of the autologin feature mandated by the
> pnfs-objects standard.
> It is called from objlayoutdriver.ko in the kernel.
> 
> Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Committed...

steved.
> ---
>  configure.ac                |    1 +
>  utils/Makefile.am           |    1 +
>  utils/osd_login/Makefile.am |   13 +++++
>  utils/osd_login/osd_login   |  102 +++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 117 insertions(+), 0 deletions(-)
>  create mode 100644 utils/osd_login/Makefile.am
>  create mode 100755 utils/osd_login/osd_login
> 
> diff --git a/configure.ac b/configure.ac
> index 67e8d2d..011a2bf 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -467,6 +467,7 @@ AC_CONFIG_FILES([
>  	utils/nfsidmap/Makefile
>  	utils/showmount/Makefile
>  	utils/statd/Makefile
> +	utils/osd_login/Makefile
>  	tests/Makefile
>  	tests/nsm_client/Makefile])
>  AC_OUTPUT
> diff --git a/utils/Makefile.am b/utils/Makefile.am
> index d074b85..c7e5d27 100644
> --- a/utils/Makefile.am
> +++ b/utils/Makefile.am
> @@ -28,6 +28,7 @@ SUBDIRS = \
>  	nfsstat \
>  	showmount \
>  	statd \
> +	osd_login \
>  	$(OPTDIRS)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
> new file mode 100644
> index 0000000..e931e36
> --- /dev/null
> +++ b/utils/osd_login/Makefile.am
> @@ -0,0 +1,13 @@
> +## Process this file with automake to produce Makefile.in
> +
> +OSD_LOGIN_FILES= osd_login
> +
> +EXTRA_DIST= $(OSD_LOGIN_FILES)
> +
> +all-local: $(OSD_LOGIN_FILES)
> +
> +install-data-hook:
> +	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
> +
> +MAINTAINERCLEANFILES = Makefile.in
> +
> diff --git a/utils/osd_login/osd_login b/utils/osd_login/osd_login
> new file mode 100755
> index 0000000..161a487
> --- /dev/null
> +++ b/utils/osd_login/osd_login
> @@ -0,0 +1,102 @@
> +#!/bin/bash
> +#
> +# osd_login : This script is part of the autologin feature
> +#             mandated by the pnfs-objects standard.
> +# It is called from objlayoutdriver.ko in the kernel.
> +
> +# Copyright (C) 2012, Sachin Bhamare <sbhamare@panasas.com>
> +# Copyright (C) 2012, Boaz Harrosh <bharrosh@panasas.com>
> +#
> +# This program is free software; you can redistribute it and/or modify
> +# it under the terms of the GNU General Public License version 2 as
> +# published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope that it will be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software
> +# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
> +# MA 02110-1301 USA
> +
> +umask 022
> +
> +PATH="/sbin:/usr/sbin:/bin:/usr/bin"
> +
> +iscsiadm=/sbin/iscsiadm
> +
> +protocol=""
> +portal=""
> +uri=""
> +osdname=""
> +systemid=""
> +
> +usage()
> +{
> +	echo "Usage: $0 -u <URI> -o <OSDNAME> -s <SYSTEMID>"
> +	echo "Options:"
> +	echo  "-u		target uri e.g. iscsi://<ip>:<port>"
> +	echo  "-o		osdname of the target OSD"
> +	echo  "-s 		systemid of the target OSD"
> +}
> +
> +parse_cmdline()
> +{
> +	argc=$#
> +	if [ $# -lt 3 ]; then
> +		usage
> +		exit 1
> +	fi
> +
> +	# parse the input arguments
> +	while getopts "u:o:s:" options; do
> +	    case $options in
> +		u ) uri=$OPTARG;;
> +		o ) osdname=$OPTARG;;
> +		s ) systemid=$OPTARG;;
> +		\? ) usage
> +			exit 1;;
> +		* )  usage
> +			exit 1;;
> +	    esac
> +	done
> +
> +	echo "-u : $uri"
> +	echo "-o : $osdname"
> +	echo "-s : $systemid"
> +
> +	protocol=`echo $uri | awk -F ':' '{print $1}'`
> +	portal=`echo $uri | awk -F '//' '{print $2}'`
> +}
> +
> +do_cmd()
> +{
> +	$* 2>&1 | logger &
> +}
> +
> +login_iscsi_osd()
> +{
> +	echo "osd_login: login into: $1"
> +	if ! $iscsiadm -m discovery -o nonpersistent -t sendtargets -p $1 --login; then
> +		echo "$iscsiadm -m discovery -t sendtargets -p $1 --login returned error $? !"
> +		sleep 1;
> +	fi
> +}
> +
> + echo "============= osd_login ========="
> + echo "progname : $0"
> +parse_cmdline "$@"
> +echo "protocol: $protocol"
> +echo "portal: $portal"
> +
> +case $protocol in
> +iscsi)
> +	login_iscsi_osd $portal |& logger
> +	;;
> +*)
> +	echo "osd_login: Error: protocol $protocol not supported !" | logger
> +	;;
> +esac
> +
