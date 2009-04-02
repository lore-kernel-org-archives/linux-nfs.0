From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Thu, 02 Apr 2009 20:45:34 +0300
Message-ID: <49D4F9BE.3010102@panasas.com>
References: <49D3752E.7060708@panasas.com> <49D38924.9020105@panasas.com> <49D482F6.5090000@panasas.com> <20090402132742.GA24124@fieldses.org> <49D4C19F.7090608@panasas.com> <1238681800.6191.5.camel@heimdal.trondhjem.org> <20090402142256.GF24124@fieldses.org> <1238682355.6191.6.camel@heimdal.trondhjem.org> <20090402143141.GG24124@fieldses.org> <49D4E915.40705@panasas.com> <20090402165427.GA32533@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Steve Dickson <steved@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:3961 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751125AbZDBRpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 13:45:40 -0400
In-Reply-To: <20090402165427.GA32533@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2009, 19:54 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Apr 02, 2009 at 07:34:29PM +0300, Benny Halevy wrote:
>> On Apr. 02, 2009, 17:31 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Thu, Apr 02, 2009 at 10:25:55AM -0400, Trond Myklebust wrote:
>>>> On Thu, 2009-04-02 at 10:22 -0400, J. Bruce Fields wrote:
>>>>> On Thu, Apr 02, 2009 at 10:16:40AM -0400, Trond Myklebust wrote:
>>>>>> On Thu, 2009-04-02 at 16:46 +0300, Benny Halevy wrote:
>>>>>>> Trond, please speak up if you want to remove CONFIG_NFS_V4_1 as well.
>>>>>>> On the client side minorversion 1 will be used only if the user
>>>>>>> explicitly asked for it with mount -o minorversion=1.
>>>>>> I'd feel more comfortable with being able to compile it out until the
>>>>>> stability of the code has been established. I'd certainly want to be
>>>>>> able to do that on the server side, since it has no other means to
>>>>>> restrict the protocol version should it turn out that NFSv4.1 has some
>>>>>> fatal condition.
>>>>> I think it's acceptable given an interface that allows choosing the
>>>>> supported minorversion at runtime (and that defaults 4.1 to off).
>>>> Is there such an interface on the server?
>>> That's the patch Benny just posted.  It seems like a pretty simple
>>> extension of the existing version-choosing interface
>>> (/proc/fs/nfsd/versions), though I think the version he posted defaults
>>> 4.1 to on?  I need to take another look.
>> That's right.  This can be changed trivially,
>> but I'll have to find and work the reason why the settings reset on
>> service nfs restart, otherwise it will reset itself.
> 
> Maybe you're starting and stopping the server using distro init scripts
> that load and unload the nfsd module?

I'm using redhat's /etc/init.d/nfs
My impression was that it doesn't unload the nfsd module when the service
is stopped.  However it does run modprobe on "start".  I wonder if that's
causing the module to reload.

Here's their script for Fedora 9:

#!/bin/sh
#
# nfs           This shell script takes care of starting and stopping
#               the NFS services.
#
# chkconfig: - 60 20
# description: NFS is a popular protocol for file sharing across TCP/IP \
#              networks. This service provides NFS server functionality, \
#              which is configured via the /etc/exports file.
# probe: true
# config: /etc/sysconfig/nfs

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
if [ ! -f /etc/sysconfig/network ]; then
    exit 6
fi

. /etc/sysconfig/network

# Check that networking is up.
[ "${NETWORKING}" = "no" ] && exit 6

[ -x /usr/sbin/rpc.nfsd ] || exit 5
[ -x /usr/sbin/rpc.mountd ] || exit 5
[ -x /usr/sbin/exportfs ] || exit 5

# Don't fail if /etc/exports doesn't exist; create a bare-bones version and continue.
[ -r /etc/exports ] || \
    { touch /etc/exports && chmod u+rw,g+r,o+r /etc/exports ; } || \
    { echo "/etc/exports does not exist" ; exit 0 ; }

# Check for and source configuration file otherwise set defaults
[ -f /etc/sysconfig/nfs ] && . /etc/sysconfig/nfs

[ -z "$MOUNTD_NFS_V2" ] && MOUNTD_NFS_V2=default
[ -z "$MOUNTD_NFS_V3" ] && MOUNTD_NFS_V3=default

# Number of servers to be started by default
[ -z "$RPCNFSDCOUNT" ] && RPCNFSDCOUNT=8

# Remote quota server
[ -z "$RQUOTAD" ] && RQUOTAD=`type -path rpc.rquotad`

RETVAL=0

# See how we were called.
case "$1" in
  start)
	# Start daemons.
	[ -x /usr/sbin/rpc.svcgssd ] && /sbin/service rpcsvcgssd start

	# Load the nfsd module so /proc/fs/nfsd will exist
	[ "$NFSD_MODULE" != "noload" ] && {
		[ -x /sbin/modprobe ] && /sbin/modprobe nfsd
	}

	action $"Starting NFS services: " /usr/sbin/exportfs -r

	# Set the ports lockd should listen on
	if [ -n "$LOCKD_TCPPORT" ]; then
	    /sbin/sysctl -w fs.nfs.nlm_tcpport=$LOCKD_TCPPORT >/dev/null 2>&1
	fi
	if [ -n "$LOCKD_UDPPORT" ]; then
	    /sbin/sysctl -w fs.nfs.nlm_udpport=$LOCKD_UDPPORT >/dev/null 2>&1
	fi

	if [ -n "$RQUOTAD" -a "$RQUOTAD" != "no" ]; then
	    echo -n $"Starting NFS quotas: "
		[ -n "$RQUOTAD_PORT" ] \
			&& RPCRQUOTADOPTS="$RPCRQUOTADOPTS -p $RQUOTAD_PORT"
	    daemon rpc.rquotad $RPCRQUOTADOPTS
		RETVAL=$?
	    echo
	fi
	echo -n $"Starting NFS daemon: "
	daemon rpc.nfsd $RPCNFSDARGS $RPCNFSDCOUNT
	RETVAL=$?
	echo
	[ $RETVAL -ne 0 ] && exit $RETVAL

	[ -n "$MOUNTD_PORT" ] \
	&& RPCMOUNTDOPTS="$RPCMOUNTDOPTS -p $MOUNTD_PORT"

	case $MOUNTD_NFS_V1 in
	no|NO)
	    RPCMOUNTDOPTS="$RPCMOUNTDOPTS --no-nfs-version 1" ;;
	esac

	case $MOUNTD_NFS_V2 in
	no|NO)
	    RPCMOUNTDOPTS="$RPCMOUNTDOPTS --no-nfs-version 2" ;;
	esac

	case $MOUNTD_NFS_V3 in
	no|NO)
	    RPCMOUNTDOPTS="$RPCMOUNTDOPTS --no-nfs-version 3" ;;
	esac

	echo -n $"Starting NFS mountd: "
	daemon rpc.mountd $RPCMOUNTDOPTS
	RETVAL=$?
	echo
	touch /var/lock/subsys/nfs

	# Let rpc.idmapd know that rpc.mountd just started
	[ -x /usr/sbin/rpc.idmapd ] && /sbin/service rpcidmapd condstart

	;;
  stop)
	# Stop daemons.
	echo -n $"Shutting down NFS mountd: "
	killproc rpc.mountd
	echo
	echo -n $"Shutting down NFS daemon: "
	killproc nfsd -2
	echo
	if [ -n "$RQUOTAD" -a "$RQUOTAD" != "no" ]; then
		echo -n $"Shutting down NFS quotas: "
		killproc rpc.rquotad
		RETVAL=$?
		echo
	fi
	# Reset the lockd ports if they were set
	if [ -n "$LOCKD_TCPPORT" ]; then
	    /sbin/sysctl -w fs.nfs.nlm_tcpport=0 >/dev/null 2>&1
	fi
	if [ -n "$LOCKD_UDPPORT" ]; then
	    /sbin/sysctl -w fs.nfs.nlm_udpport=0 >/dev/null 2>&1
	fi
	# Do it the last so that clients can still access the server
	# when the server is running.
	cnt=`/usr/sbin/exportfs -v | /usr/bin/wc -l`	
	if [ $cnt -gt 0 ]; then 
		action $"Shutting down NFS services: " /usr/sbin/exportfs -au
	else
		action $"Shutting down NFS services: " /bin/false
	fi
	[ -x /usr/sbin/rpc.svcgssd ] && /sbin/service rpcsvcgssd stop
	rm -f /var/lock/subsys/nfs
	;;
  status)
	[ -x /usr/sbin/rpc.svcgssd ] && /sbin/service rpcsvcgssd status
	status rpc.mountd
	status nfsd
	if [ -n "$RQUOTAD" -a "$RQUOTAD" != "no" ]; then
		status rpc.rquotad
	fi
	RETVAL=$?
	;;
  restart)
	$0 stop
	$0 start
	;;
  reload)
	/usr/sbin/exportfs -r
	touch /var/lock/subsys/nfs
	;;
  probe)
	if [ ! -f /var/lock/subsys/nfs ] ; then
	  echo $"start"; exit 0
	fi
	/sbin/pidof rpc.mountd >/dev/null 2>&1; MOUNTD="$?"
	/sbin/pidof nfsd >/dev/null 2>&1; NFSD="$?"
	if [ $MOUNTD = 1 -o $NFSD = 1 ] ; then
	  echo $"restart"; exit 0
	fi
	if [ /etc/exports -nt /var/lock/subsys/nfs ] ; then
	  echo $"reload"; exit 0
	fi
	;;
  condrestart)
	[ -x /usr/sbin/rpc.svcgssd ] && /sbin/service rpcsvcgssd condrestart
  	[ -f /var/lock/subsys/nfs ] && {
		$0 stop
		$0 start
	}
	;;
  *)
	echo $"Usage: nfs {start|stop|status|restart|reload|condrestart}"
	RETVAL=3
	;;
esac

exit $RETVAL



> 
> --b.
